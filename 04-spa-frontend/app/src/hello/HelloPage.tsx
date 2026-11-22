import { useHello } from './useHello.ts'

export function HelloPage() {
  const hello = useHello()

  if (hello.isPending) {
    return <p>読み込み中</p>
  }

  if (hello.isError) {
    return <p>メッセージを取得できませんでした。</p>
  }

  return <p>{hello.data.message}</p>
}
