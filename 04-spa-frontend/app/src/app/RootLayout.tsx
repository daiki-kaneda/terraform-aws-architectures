import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { Outlet } from '@tanstack/react-router'

const queryClient = new QueryClient()

export function RootLayout() {
  return (
    <QueryClientProvider client={queryClient}>
      <Outlet />
    </QueryClientProvider>
  )
}
