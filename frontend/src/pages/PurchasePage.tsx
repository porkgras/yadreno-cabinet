import { useQuery } from '@tanstack/react-query'
import { useState } from 'react'
import { ShoppingCart, Star, CreditCard, Coins } from 'lucide-react'
import api from '../services/api'
import toast from 'react-hot-toast'

interface Tariff {
  id: number
  name: string
  description: string
  price: number
  currency: string
  traffic_limit: number
  period_days: number
  max_devices: number
  is_active: bool
  price_formatted: string
}

export function PurchasePage() {
  const [selectedTariff, setSelectedTariff] = useState<number | null>(null)
  const [selectedMethod, setSelectedMethod] = useState<string>('stars')

  const { data, isLoading } = useQuery<{ tariffs: Tariff[] }>({
    queryKey: ['tariffs'],
    queryFn: async () => {
      const response = await api.get('/tariffs')
      return response.data
    }
  })

  const handlePurchase = async () => {
    if (!selectedTariff) {
      toast.error('Выберите тариф')
      return
    }

    try {
      const response = await api.post('/payments/create', {
        tariff_id: selectedTariff,
        method: selectedMethod
      })
      
      if (response.data.payment_url) {
        window.open(response.data.payment_url, '_blank')
        toast.success('Платеж создан, следуйте инструкциям')
      }
    } catch (error) {
      toast.error('Ошибка при создании платежа')
    }
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  const tariffs = data?.tariffs || []

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">
        Купить VPN
      </h1>

      <div className="grid gap-6 md:grid-cols-3">
        {tariffs.map((tariff) => (
          <div
            key={tariff.id}
            className={`card p-6 cursor-pointer transition-all ${
              selectedTariff === tariff.id
                ? 'ring-2 ring-primary-600 shadow-lg'
                : 'hover:shadow-lg'
            }`}
            onClick={() => setSelectedTariff(tariff.id)}
          >
            <h3 className="text-xl font-bold text-gray-900 dark:text-white">
              {tariff.name}
            </h3>
            <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
              {tariff.description}
            </p>
            <div className="mt-4">
              <span className="text-3xl font-bold text-gray-900 dark:text-white">
                {tariff.price_formatted}
              </span>
            </div>
            <div className="mt-4 space-y-2 text-sm text-gray-600 dark:text-gray-400">
              <p>📊 {tariff.traffic_limit === 0 ? 'Безлимитный' : `${tariff.traffic_limit} GB`} трафик</p>
              <p>📅 {tariff.period_days} дней</p>
              <p>📱 {tariff.max_devices} устройств</p>
            </div>
          </div>
        ))}
      </div>

      {selectedTariff && (
        <div className="mt-8 card p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Способ оплаты
          </h3>
          <div className="grid gap-4 md:grid-cols-3">
            <button
              className={`p-4 rounded-lg border-2 transition-all ${
                selectedMethod === 'stars'
                  ? 'border-primary-600 bg-primary-50 dark:bg-primary-900/20'
                  : 'border-gray-200 dark:border-gray-700 hover:border-gray-300'
              }`}
              onClick={() => setSelectedMethod('stars')}
            >
              <div className="flex items-center justify-center">
                <Star className="h-6 w-6 text-yellow-500 mr-2" />
                <span>Telegram Stars</span>
              </div>
            </button>
            <button
              className={`p-4 rounded-lg border-2 transition-all ${
                selectedMethod === 'usdt'
                  ? 'border-primary-600 bg-primary-50 dark:bg-primary-900/20'
                  : 'border-gray-200 dark:border-gray-700 hover:border-gray-300'
              }`}
              onClick={() => setSelectedMethod('usdt')}
            >
              <div className="flex items-center justify-center">
                <Coins className="h-6 w-6 text-green-500 mr-2" />
                <span>USDT</span>
              </div>
            </button>
            <button
              className={`p-4 rounded-lg border-2 transition-all ${
                selectedMethod === 'card'
                  ? 'border-primary-600 bg-primary-50 dark:bg-primary-900/20'
                  : 'border-gray-200 dark:border-gray-700 hover:border-gray-300'
              }`}
              onClick={() => setSelectedMethod('card')}
            >
              <div className="flex items-center justify-center">
                <CreditCard className="h-6 w-6 text-blue-500 mr-2" />
                <span>Банковская карта</span>
              </div>
            </button>
          </div>

          <button
            onClick={handlePurchase}
            className="mt-6 w-full btn-primary flex items-center justify-center"
          >
            <ShoppingCart className="h-5 w-5 mr-2" />
            Оплатить
          </button>
        </div>
      )}
    </div>
  )
}
