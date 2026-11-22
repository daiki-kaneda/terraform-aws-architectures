import { createFileRoute } from '@tanstack/react-router'
import { HelloPage } from '../hello/HelloPage.tsx'

export const Route = createFileRoute('/')({
  component: HelloPage,
})
