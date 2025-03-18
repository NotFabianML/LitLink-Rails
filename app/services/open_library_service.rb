class OpenLibraryService
  BASE_URL = 'https://openlibrary.org'
  DEFAULT_COVER = 'https://placehold.co/150x225?text=No+Cover'.freeze

  class << self
    def search_books(preferences)
      query = build_query(preferences)
      response = HTTParty.get("#{BASE_URL}/search.json", {
        query: {
          q: query,
          fields: 'title,author_name,subject,first_publish_year,number_of_pages_median,isbn,cover_i,key',
          language: 'eng',
          limit: 20
        }
      })

      process_results(response.parsed_response['docs'])
    rescue StandardError => e
      Rails.logger.error "OpenLibrary Error: #{e.message}"
      []
    end

    private

    def process_results(docs)
      books = docs.map do |doc|
        {
          title: doc['title'],
          authors: doc['author_name'] || [],
          subjects: doc['subject']&.first(5) || [],
          publish_date: doc['first_publish_year']&.to_s,
          number_of_pages_median: doc['number_of_pages_median'],
          isbn: doc['isbn']&.first(5) || [],
          cover_url: cover_url(doc['cover_i']),
          work_key: doc['key'],
          description: fetch_description(doc['key'])
        }
      end

      books
    end

    def fetch_description(work_key)
      response = HTTParty.get("#{BASE_URL}#{work_key}.json")
      extract_description(response.parsed_response)
    rescue StandardError
      'Descripción no disponible'
    end

    def extract_description(data)
      sources = [
        data.dig('description', 'value'),
        data['description'],
        data.dig('notes', 'value'),
        data.dig('first_sentence', 'value'),
        data.dig('excerpts', 0, 'text', 'value')
      ]

      sources.find { |text| text.is_a?(String) && text.length.between?(50, 2000) } || 'Descripción no disponible'
    end

    def cover_url(cover_id, size: :medium)
      return DEFAULT_COVER unless cover_id

      sizes = { small: '-S', medium: '-M', large: '-L' }
      "https://covers.openlibrary.org/b/id/#{cover_id}#{sizes[size]}.jpg"
    end

    def build_query(preferences)
      [
        preferences[:liked_books]&.map { |b| "title:\"#{b}\"" }&.join(' OR '),
        preferences[:authors]&.map { |a| "author:\"#{a}\"" }&.join(' OR '),
        preferences[:genres]&.map { |g| "subject:\"#{g}\"" }&.join(' OR ')
      ].compact.reject(&:empty?).join(' OR ')
    end
  end
end
