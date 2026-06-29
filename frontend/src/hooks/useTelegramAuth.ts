import { useState } from 'react'
import { authService } from '../services/auth'

declare global {
  interface Window {
    TelegramLoginWidget: any
  }
}

export function useTelegramAuth() {
  const [isLoading, setIsLoading] = useState(false)

  const loginWithTelegram = () => {
    setIsLoading(true)
    // Временная заглушка для демонстрации
    setTimeout(() => {
      const mockData = {
        id: 123456789,
        first_name: 'Test',
        username: 'test_user',
      }
      authService.loginWithTelegram(mockData).then(() => {
        setIsLoading(false)
        window.location.href = '/'
      })
    }, 1000)
  }

  return { loginWithTelegram, isLoading }
}
