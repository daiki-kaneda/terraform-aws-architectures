import { helloResponseSchema, type HelloResponse } from './dto.ts'
import type { HelloGateway } from './gateway.ts'

export function createHttpHelloGateway(baseUrl: string): HelloGateway {
  return {
    async get(): Promise<HelloResponse> {
      if (baseUrl === '') {
        throw new Error('APIのURLが設定されていません。')
      }

      const response = await fetch(new URL('/', baseUrl))
      if (!response.ok) {
        throw new Error('APIの呼び出しに失敗しました。')
      }

      return helloResponseSchema.parse(await response.json())
    },
  }
}
