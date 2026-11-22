import type { HelloResponse } from './dto.ts'
import type { HelloGateway } from './gateway.ts'

export function getHello(gateway: HelloGateway): Promise<HelloResponse> {
  return gateway.get()
}
