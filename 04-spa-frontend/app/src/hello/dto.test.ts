import { describe, expect, it } from 'vitest'
import { helloResponseSchema } from './dto.ts'

describe('helloResponseSchema', () => {
  it('accepts a message', () => {
    expect(
      helloResponseSchema.parse({ message: 'Hello from Lambda!' }),
    ).toEqual({
      message: 'Hello from Lambda!',
    })
  })

  it('rejects a response without a message', () => {
    expect(() => helloResponseSchema.parse({})).toThrow()
  })
})
