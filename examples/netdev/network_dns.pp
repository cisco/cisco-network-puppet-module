network_dns { 'settings':
    domain   => 'foo.bar.com',
    hostname => 'foo',
    search   => ['test.com', 'test.net'],
    servers  => ['8.8.8.8', '2001:4860:4860::8888'],
  }
