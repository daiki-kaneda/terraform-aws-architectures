import { z } from 'zod'

export const helloResponseSchema = z.object({
  message: z.string().min(1),
})

export type HelloResponse = z.infer<typeof helloResponseSchema>
