import type { HelloResponse } from './dto.ts'

export type HelloGateway = {
  get: () => Promise<HelloResponse>
}
