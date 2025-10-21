/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    // This is required for standalone output
    outputFileTracingRoot: process.cwd(),
  },
  output: 'standalone',
  // Add other configurations as needed
  reactStrictMode: true,
  swcMinify: true,
}

module.exports = nextConfig
