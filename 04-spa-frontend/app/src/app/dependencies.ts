import { create } from 'zustand'
import type { HelloGateway } from '../hello/gateway.ts'
import { createHttpHelloGateway } from '../hello/httpGateway.ts'

type Dependencies = {
  helloGateway: HelloGateway
}

export const useDependencies = create<Dependencies>(() => ({
  helloGateway: createHttpHelloGateway(import.meta.env.VITE_API_BASE_URL ?? ''),
}))
