import { useQuery } from '@tanstack/react-query'
import { useDependencies } from '../app/dependencies.ts'
import { getHello } from './getHello.ts'

export function useHello() {
  const helloGateway = useDependencies((state) => state.helloGateway)

  return useQuery({
    queryKey: ['hello'],
    queryFn: () => getHello(helloGateway),
    retry: false,
  })
}
