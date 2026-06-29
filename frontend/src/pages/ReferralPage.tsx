import { useQuery } from '@tanstack/react-query'
import { Copy, Users, Gift, TrendingUp } from 'lucide-react'
import api from '../services/api'
import toast from 'react-hot-toast'

interface ReferralInfo {
  enabled: boolean
  referral_link: string
  levels: Array<{
    level: number
    percent: number
    enabled: boolean
  }>
  earnings: number
  currency: string
  total_referrals: number
  referrals: Array<{
    id: number
    username: string
    joined_at: string
    level: number
    earnings: number
  }>
}

export function ReferralPage() {
  const { data, isLoading } = useQuery<ReferralInfo>({
    queryKey: ['referrals'],
    queryFn: async () => {
      const response = await api.get('/referrals/info')
      return response.data
    }
  })

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text)
    toast.success('Ссылка скопирована!')
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  if (!data || !data.enabled) {
    return (
      <div className="card p-12 text-center">
        <Gift className="h-16 w-16 text-gray-400 mx-auto mb-4" />
        <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
          Реферальная система отключена
        </h3>
        <p className="text-gray-600 dark:text-gray-400">
          Следите за обновлениями
        </p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
        Реферальная программа
      </h1>

      <div className="grid gap-4 md:grid-cols-3">
        <div className="card p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 dark:text-gray-400">Заработано</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {data.earnings} {data.currency}
              </p>
            </div>
            <TrendingUp className="h-8 w-8 text-green-500" />
          </div>
        </div>
        <div className="card p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 dark:text-gray-400">Рефералов</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {data.total_referrals}
              </p>
            </div>
            <Users className="h-8 w-8 text-blue-500" />
          </div>
        </div>
        <div className="card p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600 dark:text-gray-400">Уровней</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {data.levels.filter(l => l.enabled).length}
              </p>
            </div>
            <Gift className="h-8 w-8 text-purple-500" />
          </div>
        </div>
      </div>

      <div className="card p-6">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Ваша реферальная ссылка
        </h3>
        <div className="flex flex-col sm:flex-row gap-4">
          <input
            type="text"
            value={data.referral_link}
            readOnly
            className="flex-1 px-4 py-2 bg-gray-50 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-lg text-sm"
          />
          <button
            onClick={() => copyToClipboard(data.referral_link)}
            className="btn-primary flex items-center justify-center"
          >
            <Copy className="h-4 w-4 mr-2" />
            Копировать
          </button>
        </div>
      </div>

      {data.levels.filter(l => l.enabled).length > 0 && (
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Уровни вознаграждения
          </h3>
          <div className="grid gap-4 md:grid-cols-3">
            {data.levels.filter(l => l.enabled).map((level) => (
              <div key={level.level} className="bg-gray-50 dark:bg-gray-700 p-4 rounded-lg text-center">
                <p className="text-sm text-gray-600 dark:text-gray-400">Уровень {level.level}</p>
                <p className="text-2xl font-bold text-primary-600 dark:text-primary-400">
                  {level.percent}%
                </p>
              </div>
            ))}
          </div>
        </div>
      )}

      {data.referrals.length > 0 && (
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Мои рефералы
          </h3>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-gray-200 dark:border-gray-700">
                  <th className="text-left py-2 text-gray-600 dark:text-gray-400">Пользователь</th>
                  <th className="text-left py-2 text-gray-600 dark:text-gray-400">Уровень</th>
                  <th className="text-left py-2 text-gray-600 dark:text-gray-400">Заработано</th>
                  <th className="text-left py-2 text-gray-600 dark:text-gray-400">Дата</th>
                </tr>
              </thead>
              <tbody>
                {data.referrals.map((ref) => (
                  <tr key={ref.id} className="border-b border-gray-100 dark:border-gray-800">
                    <td className="py-2 text-gray-900 dark:text-white">@{ref.username}</td>
                    <td className="py-2 text-gray-600 dark:text-gray-400">{ref.level}</td>
                    <td className="py-2 text-gray-900 dark:text-white">{ref.earnings} {data.currency}</td>
                    <td className="py-2 text-gray-600 dark:text-gray-400">
                      {new Date(ref.joined_at).toLocaleDateString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
