module RequestSpecHelper
  # Parse JSON response to ruby hash
  def json
    body = response.body
    body = page.body if body.empty?

    JSON.parse(body)
  end
end
