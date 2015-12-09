# The Schema.org data

SCHEMA_ORG = {
  "@context" => "http://schema.org",
  "@type" => "Organization",
  name: "Plezi",
  url: 'http://www.plezi.io',
  description: %q{Websockets and REST for Ruby - Plezi is a Ruby framework for realtime web applications. Easier than Faye, more fun than socket.io. Works with Rails, Sintra, Rack and on it's own.},
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
	}.to_json