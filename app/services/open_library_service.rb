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

  # def self.get_book(book_id)
  #   # Primero intentar por ISBN
  #   response = get("/isbn/#{book_id}.json")
  #   return parse_book_details(response.parsed_response) if response.success?

  #   # Si falla, intentar por work key (ej: "/works/OL123W")
  #   response = get("#{book_id}.json")
  #   return parse_book_details(response.parsed_response) if response.success?

  #   nil
  # rescue
  #   nil
  # end
  #
  ## GET completo de detalles para un work (o ISBN)
  def self.get_book(book_id)
    # Primero intento ISBN
    resp_isbn = get("/isbn/#{book_id}.json")
    if resp_isbn.success?
      return parse_edition_details(resp_isbn.parsed_response)
    end

    # Luego intento work key
    work_resp = get("#{book_id}.json")
    return nil unless work_resp.success?
    work = work_resp.parsed_response

    # 1) Autores: extraigo claves y hago peticiones
    author_keys = work["authors"]&.map { |a| a.dig("author", "key") } || []
    authors = author_keys.map do |ak|
      a = get("#{ak}.json")
      a.success? ? a.parsed_response["name"] : nil
    end.compact

    # 2) Edición: tomo la primera para páginas, fecha e ISBN
    editions_resp = get("#{book_id}/editions.json", query: { limit: 1 })
    edition = editions_resp.success? ? editions_resp.parsed_response["entries"].first : nil

    pages         = edition&.dig("number_of_pages")
    publish_date  = edition&.dig("publish_date")
    isbn_list     = edition&.dig("isbn_10") || edition&.dig("isbn_13") || []
    isbn          = isbn_list.first

    # 3) Armo el hash final
    {
      title:         work["title"],
      authors:       authors,
      genres:        work["subjects"] || [],
      publish_date:  publish_date,
      pages:         pages,
      isbn:          isbn,
      cover_url:     cover_url(work["covers"]&.first, :medium),
      description:   extract_description(work)
    }
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

  # Parse de cuando obtengo un JSON de ISBN directamente
  def self.parse_edition_details(data)
    authors = (data["authors"] || []).map { |a| a["name"] }.compact
    {
      title:       data["title"],
      authors:     authors,
      genres:      data["subjects"] || [],
      publish_date: data["publish_date"],
      pages:       data["number_of_pages"],
      isbn:        data["isbn_10"]&.first || data["isbn_13"]&.first,
      cover_url:   cover_url(data["covers"]&.first, :medium),
      description: data["description"] || "Descripción no disponible"
    }
  end

  # Saco descripción con tu heurística existente
  def self.extract_description(data)
    sources = [
      data.dig("description", "value"),
      data["description"],
      data.dig("first_sentence", "value"),
      data.dig("excerpts", 0, "text", "value")
    ].compact
    sources.find { |t| t.length.between?(50, 2000) } ||
      "Descripción no disponible"
  end

  # Genera URL de portada
  def self.cover_url(cover_id, size = :medium)
    return "https://placehold.co/150x225?text=No+Cover" unless cover_id
    "https://covers.openlibrary.org/b/id/#{cover_id}#{COVER_SIZES[size]}.jpg"
  end
end
