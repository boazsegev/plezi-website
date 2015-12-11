# The Schema.org data

# Description
SCHEMA_ABOUT = %q{Websockets and REST for Ruby - Plezi is a Ruby framework for realtime web applications. Easier than Faye, more fun than socket.io. Works with Rails, Sintra, Rack and on it's own.}

# Schema JSON
SCHEMA_ORG = {
  "@context" => "http://schema.org",
  "@type" => "WebSite",
  url: 'http://www.plezi.io',
  name: "Plezi",
  description: SCHEMA_ABOUT,
  keywords: "websockets, websocket, ruby, framework, realtime, real-time, http, rest, restful, crud, easy",
  image: 'http://www.plezi.io/images/logo_thick_dark.png',
  # potentialAction: {
  #     "@type" => "SearchAction",
  #     target: "http://example.com/search?&q={query}",
  #     "query-input" => "required",
  #   },
  author: [
    {
      "@type" => "Person",
      name: "Bo (Myst)",
      url: 'http://stackoverflow.com/users/4025095/myst',
      email: "bo(at)plezi.io",
    }
  ],
  sourceOrganization: {
    "@context" => "http://schema.org",
    "@type" => "Organization",
    name: "Plezi",
    url: 'http://www.plezi.io',
    description: SCHEMA_ABOUT,
    logo: 'http://www.plezi.io/images/logo_thick_dark.png',
    image: 'http://www.plezi.io/images/logo_thick_dark.png',
    email: "bo(at)plezi.io",
    member: [
      {
        "@type" => "Person",
        name: "Bo (Myst)",
        url: 'http://stackoverflow.com/users/4025095/myst'
      }
    ],
  },
}.to_json