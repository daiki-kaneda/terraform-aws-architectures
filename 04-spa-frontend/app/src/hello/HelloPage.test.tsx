import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import { afterEach, expect, it } from 'vitest'
import { useDependencies } from '../app/dependencies.ts'
import { HelloPage } from './HelloPage.tsx'
import { createHttpHelloGateway } from './httpGateway.ts'

afterEach(() => {
  useDependencies.setState({
    helloGateway: createHttpHelloGateway(import.meta.env.VITE_API_BASE_URL ?? ''),
  })
})

it('shows the message from the gateway', async () => {
  useDependencies.setState({
    helloGateway: {
      get: async () => ({ message: 'Hello from Lambda!' }),
    },
  })

  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  })

  render(
    <QueryClientProvider client={queryClient}>
      <HelloPage />
    </QueryClientProvider>,
  )

  expect(await screen.findByText('Hello from Lambda!')).toBeInTheDocument()
})
