
# UniPath Frontend Setup

## Installation

Install dependencies:

    npm install

Start the development server:

    npm run dev

Open the local URL displayed by Vite.

## API Configuration

Copy `.env.example` to `.env.local`.

For fixture mode:

    VITE_USE_FIXTURES=true

For real-server mode:

    VITE_USE_FIXTURES=false
    VITE_API_BASE_URL=http://localhost:5000

The backend URL is an example. Confirm the actual address with the Flask team.

Restart Vite after changing environment variables.

## HTTP Adapter

The HTTP adapter is located at `src/API/client.js`.

Fixtures are defined in `src/fixtures/responses.js`.

Fixture mode must be explicitly enabled. Failed real-server requests never automatically switch to fixtures.

The current fixtures use temporary test endpoints, not confirmed UniPath API contracts.

## Testing

Run automated tests:

    npm test

Run the production build check:

    npx vite build

The HTTP adapter tests cover fixture responses, missing fixtures, real HTTP requests, server errors, HTTP 204 responses, POST payloads, simulated fixture errors, and fixture payload validation.

These unit tests do not replace browser-level testing or real Flask/PostgreSQL integration.
