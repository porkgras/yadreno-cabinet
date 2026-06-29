import { useState, useEffect } from 'react'
import { authService } from '../services/auth'

export function useAuth() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('access_token')
    if (token) {
      authService.verifyToken(token).then((valid) => {
        setIsAuthenticated(valid)
        setIsLoading(false)
      })
    } else {
      setIsLoading(false)
    }
  }, [])

  return { isAuthenticated, isLoading }
}
