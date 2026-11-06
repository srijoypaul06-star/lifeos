export interface BodyMeasurement {
  id: string
  date: string
  weightKg: number
  waistCm?: number
  chestCm?: number
  armCm?: number
  hipCm?: number
  notes?: string
}

export interface Exercise {
  id: string
  name: string
  muscleGroup: string
  equipment: string
}

export interface WorkoutSet {
  setNumber: number
  reps: number
  weightKg: number
}

export interface WorkoutSession {
  id: string
  date: string
  workoutName: string
  durationMinutes: number
  exerciseName: string
  muscleGroup: string
  sets: WorkoutSet[]
  notes?: string
}

export interface RunningSession {
  id: string
  date: string
  distanceKm: number
  durationMinutes: number
  notes?: string
}

export interface FitnessGoals {
  targetWeightKg: number
  weeklyGymSessions: number
  weeklyRunningSessions: number
}
