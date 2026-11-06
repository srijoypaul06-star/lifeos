
import { useEffect, useState } from 'react'
import {
  getDailyRecord,
  getTodayKey,
  saveDailyRecord,
} from '../database/db'

export function useDailyRecord() {
  const [water, setWater] = useState(0)
  const [completedHabitIds, setCompletedHabitIds] = useState<number[]>([])
  const [loading, setLoading] = useState(true)

  const today = getTodayKey()

  // Load today's saved data
  useEffect(() => {
    let active = true

    async function loadData() {
      try {
        const record = await getDailyRecord(today)

        if (!active) return

        if (record) {
          setWater(record.waterMl)
          setCompletedHabitIds(record.completedHabitIds)
        } else {
          setWater(0)
          setCompletedHabitIds([])
        }
      } catch (error) {
        console.error('Failed to load daily data:', error)
      } finally {
        if (active) {
          setLoading(false)
        }
      }
    }

    loadData()

    return () => {
      active = false
    }
  }, [today])

  // Automatically save changes
  useEffect(() => {
    if (loading) return

    const timeout = window.setTimeout(() => {
      saveDailyRecord({
        date: today,
        waterMl: water,
        completedHabitIds: completedHabitIds,
        updatedAt: Date.now(),
      }).catch((error) => {
        console.error('Failed to save daily data:', error)
      })
    }, 300)

    return () => {
      window.clearTimeout(timeout)
    }
  }, [water, completedHabitIds, loading, today])

  // Toggle habit completion
  function toggleHabit(id: number) {
    setCompletedHabitIds((previous) =>
      previous.includes(id)
        ? previous.filter((item) => item !== id)
        : [...previous, id]
    )
  }

  // Add water
  function addWater(amount = 250) {
    setWater((previous) => previous + amount)
  }

  return {
    water,
    completedHabitIds,
    loading,
    toggleHabit,
    addWater,
  }
}
