import { describe, expect, it } from 'vitest'
import type { HelloGateway } from './gateway.ts'
import { getHello } from './getHello.ts'

describe('getHello', () => {
  it('returns the gateway result', async () => {
    const gateway: HelloGateway = {
      get: async () => ({ message: 'Hello from Lambda!' }),
    }

    await expect(getHello(gateway)).resolves.toEqual({
      message: 'Hello from Lambda!',
    })
  })
})
