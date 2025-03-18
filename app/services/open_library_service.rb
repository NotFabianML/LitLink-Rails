require "httparty"

class OpenLibraryService
  include HTTParty
  base_uri "https://openlibrary.org"
  COVER_SIZES = { small: "-S", medium: "-M", large: "-L" }.freeze

  def self.search_books(preferences)
    query = generate_search_query(preferences)
    response = get("/search.json", query: {
      q: query,
      fields: "title,author_name,subject,first_publish_year,number_of_pages_median,isbn,cover_i,key",
      language: "spa",
      limit: 20
    })

    return [] unless response.success?

    basic_books = parse_basic_books(response.parsed_response["docs"])
    books_with_descriptions(basic_books)
  end

  private

  def self.generate_search_query(preferences)
    query_parts = []

    if preferences[:favorite_books].present?
      query_parts << "(#{preferences[:favorite_books].map { |b| "title:\"#{b}\"" }.join(' OR ')})"
    end

    if preferences[:favorite_authors].present?
      query_parts << "(#{preferences[:favorite_authors].map { |a| "author:\"#{a}\"" }.join(' OR ')})"
    end

    if preferences[:favorite_genres].present?
      query_parts << "(#{preferences[:favorite_genres].map { |g| "subject:\"#{g}\"" }.join(' OR ')})"
    end

    query_parts.join(" OR ")
  end

  def self.parse_basic_books(docs)
    docs.map do |doc|
      {
        title: doc["title"],
        authors: doc["author_name"] || [],
        subjects: doc["subject"]&.take(5) || [],
        publish_date: doc["first_publish_year"]&.to_s,
        pages: doc["number_of_pages_median"],
        isbn: doc["isbn"]&.take(5) || [],
        cover_url: cover_url(doc["cover_i"], :medium),
        work_key: doc["key"],
        description: ""
      }
    end
  end

  def self.books_with_descriptions(books)
    books.map do |book|
      description = get_description(book[:work_key])
      book.merge(description: description)
    end
  end

  def self.get_description(work_key)
    return "Descripción no disponible" unless work_key
    response = get("#{work_key}.json")
    extract_description(response.parsed_response)
  rescue
    "Descripción no disponible"
  end

  def self.extract_description(data)
    sources = [
      data.dig("description", "value"),
      data["description"],
      data.dig("notes", "value"),
      data.dig("first_sentence", "value"),
      data.dig("excerpts", 0, "text", "value")
    ].compact

    sources.find { |text| text.length.between?(50, 2000) } || "Descripción no disponible"
  end

  def self.cover_url(cover_id, size = :medium)
    return "https://placehold.co/150x225?text=No+Cover" unless cover_id
    "https://covers.openlibrary.org/b/id/#{cover_id}#{COVER_SIZES[size]}.jpg"
  end

  def self.get_book(book_id)
    # Primero intentar por ISBN
    response = get("/isbn/#{book_id}.json")
    return parse_book_details(response.parsed_response) if response.success?

    # Si falla, intentar por work key (ej: "/works/OL123W")
    response = get("#{book_id}.json")
    return parse_book_details(response.parsed_response) if response.success?

    nil
  rescue
    nil
  end

  private

  def self.parse_book_details(data)
    {
      isbn: data["isbn_10"]&.first || data["isbn_13"]&.first,
      title: data["title"],
      authors: data["authors"]&.map { |a| a["name"] } || [],
      genres: data["subjects"] || [],
      publish_date: data["publish_date"],
      pages: data["number_of_pages"],
      cover_url: cover_url(data["covers"]&.first),
      description: data["description"] || get_description(data["works"]&.first["key"])
    }
  end
end
