import type { Exercise } from './types'

export const exerciseLibrary: Exercise[] = [
  { id: 'bench-press', name: 'Bench Press', muscleGroup: 'Chest', equipment: 'Barbell' },
  { id: 'incline-db-press', name: 'Incline Dumbbell Press', muscleGroup: 'Chest', equipment: 'Dumbbell' },
  { id: 'chest-fly', name: 'Cable Chest Fly', muscleGroup: 'Chest', equipment: 'Cable' },
  { id: 'push-up', name: 'Push-up', muscleGroup: 'Chest', equipment: 'Bodyweight' },
  { id: 'lat-pulldown', name: 'Lat Pulldown', muscleGroup: 'Back', equipment: 'Cable' },
  { id: 'seated-row', name: 'Seated Cable Row', muscleGroup: 'Back', equipment: 'Cable' },
  { id: 'barbell-row', name: 'Barbell Row', muscleGroup: 'Back', equipment: 'Barbell' },
  { id: 'shoulder-press', name: 'Shoulder Press', muscleGroup: 'Shoulders', equipment: 'Dumbbell' },
  { id: 'lateral-raise', name: 'Lateral Raise', muscleGroup: 'Shoulders', equipment: 'Dumbbell' },
  { id: 'rear-delt-fly', name: 'Rear Delt Fly', muscleGroup: 'Shoulders', equipment: 'Machine' },
  { id: 'barbell-curl', name: 'Barbell Curl', muscleGroup: 'Biceps', equipment: 'Barbell' },
  { id: 'hammer-curl', name: 'Hammer Curl', muscleGroup: 'Biceps', equipment: 'Dumbbell' },
  { id: 'tricep-pushdown', name: 'Tricep Pushdown', muscleGroup: 'Triceps', equipment: 'Cable' },
  { id: 'overhead-extension', name: 'Overhead Tricep Extension', muscleGroup: 'Triceps', equipment: 'Dumbbell' },
  { id: 'squat', name: 'Squat', muscleGroup: 'Legs', equipment: 'Barbell' },
  { id: 'leg-press', name: 'Leg Press', muscleGroup: 'Legs', equipment: 'Machine' },
  { id: 'leg-curl', name: 'Leg Curl', muscleGroup: 'Legs', equipment: 'Machine' },
  { id: 'calf-raise', name: 'Calf Raise', muscleGroup: 'Calves', equipment: 'Machine' },
  { id: 'crunch', name: 'Machine Crunch', muscleGroup: 'Core', equipment: 'Machine' },
  { id: 'plank', name: 'Plank', muscleGroup: 'Core', equipment: 'Bodyweight' },
]
