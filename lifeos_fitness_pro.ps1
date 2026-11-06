$ErrorActionPreference = "Stop"

# LifeOS Fitness Pro upgrade. Run from D:\Projects\lifeos.
if (-not (Test-Path ".\src\App.tsx") -or -not (Test-Path ".\src\database\db.ts")) {
  throw "Run this script from the LifeOS project root: D:\Projects\lifeos"
}

Copy-Item ".\src\database\db.ts" ".\db.ts.before-fitness-pro.bak" -Force
Copy-Item ".\src\modules\fitness\Fitness.tsx" ".\Fitness.tsx.before-fitness-pro.bak" -Force

@'
import Dexie, { type Table } from 'dexie'

export interface DailyRecord {
  date: string
  waterMl: number
  completedHabitIds: number[]
  updatedAt: number
}

export interface StoredWorkout {
  id: string
  date: string
  workoutName: string
  durationMinutes: number
  exerciseName: string
  muscleGroup: string
  sets: { setNumber: number; reps: number; weightKg: number }[]
  notes?: string
}

export interface StoredWorkoutSet {
  id: string
  setNumber: number
  reps: number
  weightKg: number
  completed: boolean
}

export interface StoredWorkoutExercise {
  id: string
  exerciseId: string
  exerciseName: string
  muscleGroup: string
  equipment: string
  sets: StoredWorkoutSet[]
}

export interface StoredWorkoutSession {
  id: string
  date: string
  workoutName: string
  durationMinutes: number
  exercises: StoredWorkoutExercise[]
  notes?: string
  totalVolumeKg: number
  completedSets: number
}

export interface StoredRun {
  id: string
  date: string
  distanceKm: number
  durationMinutes: number
  notes?: string
}

export interface StoredMeasurement {
  id: string
  date: string
  weightKg: number
  waistCm?: number
  chestCm?: number
  armCm?: number
  hipCm?: number
  notes?: string
}

export interface StoredFitnessGoal {
  id: 'main'
  targetWeightKg: number
  weeklyGymSessions: number
  weeklyRunningSessions: number
}

export interface StoredNutritionMeal {
  id: string
  date: string
  mealType: 'Breakfast' | 'Lunch' | 'Snacks' | 'Dinner'
  foodName: string
  quantityGrams: number
  calories: number
  protein: number
  carbs: number
  fat: number
}

export interface StoredNutritionGoal {
  id: 'main'
  calories: number
  protein: number
  carbs: number
  fat: number
}

class LifeOSDatabase extends Dexie {
  dailyRecords!: Table<DailyRecord, string>
  workouts!: Table<StoredWorkout, string>
  runs!: Table<StoredRun, string>
  measurements!: Table<StoredMeasurement, string>
  fitnessGoals!: Table<StoredFitnessGoal, string>
  nutritionMeals!: Table<StoredNutritionMeal, string>
  nutritionGoals!: Table<StoredNutritionGoal, string>
  workoutSessions!: Table<StoredWorkoutSession, string>

  constructor() {
    super('LifeOSDatabase')

    this.version(1).stores({
      dailyRecords: 'date, updatedAt',
    })

    this.version(2).stores({
      dailyRecords: 'date, updatedAt',
      workouts: 'id, date, workoutName, muscleGroup',
      runs: 'id, date',
      measurements: 'id, date',
      fitnessGoals: 'id',
    })

    this.version(3).stores({
      dailyRecords: 'date, updatedAt',
      workouts: 'id, date, workoutName, muscleGroup',
      runs: 'id, date',
      measurements: 'id, date',
      fitnessGoals: 'id',
      nutritionMeals: 'id, date, mealType, foodName',
      nutritionGoals: 'id',
    })

    this.version(4).stores({
      dailyRecords: 'date, updatedAt',
      workouts: 'id, date, workoutName, muscleGroup',
      runs: 'id, date',
      measurements: 'id, date',
      fitnessGoals: 'id',
      nutritionMeals: 'id, date, mealType, foodName',
      nutritionGoals: 'id',
      workoutSessions: 'id, date, workoutName',
    })
  }
}

export const db = new LifeOSDatabase()

export function getTodayKey(): string {
  const now = new Date()
  const year = now.getFullYear()
  const month = String(now.getMonth() + 1).padStart(2, '0')
  const day = String(now.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

export async function getDailyRecord(date: string): Promise<DailyRecord | undefined> {
  return db.dailyRecords.get(date)
}

export async function saveDailyRecord(record: DailyRecord): Promise<void> {
  await db.dailyRecords.put(record)
}
'@ | Set-Content -Encoding utf8 ".\src\database\db.ts"

@'
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
'@ | Set-Content -Encoding utf8 ".\src\modules\fitness\data.ts"

@'
import { useCallback, useEffect, useMemo, useState, type FormEvent, type ReactNode } from 'react'
import {
  Activity, CalendarDays, ChartNoAxesCombined, Check, ChevronDown, ChevronUp,
  Clock3, Dumbbell, Footprints, Plus, Search, Scale, Target, TimerReset,
  Trash2, Trophy, X
} from 'lucide-react'
import {
  db, getTodayKey,
  type StoredMeasurement, type StoredRun, type StoredWorkoutExercise,
  type StoredWorkoutSession, type StoredWorkoutSet
} from '../../database/db'
import { exerciseLibrary } from './data'

type Tab = 'workout' | 'running' | 'body'
type ExerciseDraft = StoredWorkoutExercise
const muscleGroups = ['All', 'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Legs', 'Calves', 'Core']
const card = 'rounded-2xl border border-white/[0.07] bg-[#111412] p-5'
const field = 'w-full rounded-xl border border-white/10 bg-[#0c100d] px-3 py-2.5 text-sm text-zinc-100 outline-none focus:border-emerald-400/50'
const label = 'mb-1.5 block text-xs font-medium text-zinc-400'
const templates: Record<string, string[]> = {
  'Push Day': ['bench-press', 'incline-db-press', 'chest-fly', 'shoulder-press', 'lateral-raise', 'tricep-pushdown'],
  'Pull Day': ['lat-pulldown', 'seated-row', 'barbell-row', 'rear-delt-fly', 'barbell-curl', 'hammer-curl'],
  'Leg Day': ['squat', 'leg-press', 'leg-curl', 'calf-raise', 'plank'],
  'Upper Body': ['bench-press', 'lat-pulldown', 'shoulder-press', 'seated-row', 'barbell-curl', 'tricep-pushdown'],
}

function makeSet(number: number): StoredWorkoutSet {
  return { id: crypto.randomUUID(), setNumber: number, reps: 12, weightKg: 0, completed: false }
}

function makeExercise(exerciseId: string): ExerciseDraft | null {
  const exercise = exerciseLibrary.find(item => item.id === exerciseId)
  if (!exercise) return null
  return {
    id: crypto.randomUUID(),
    exerciseId: exercise.id,
    exerciseName: exercise.name,
    muscleGroup: exercise.muscleGroup,
    equipment: exercise.equipment,
    sets: [makeSet(1), makeSet(2), makeSet(3)],
  }
}

function Fitness() {
  const [tab, setTab] = useState<Tab>('workout')
  const [sessions, setSessions] = useState<StoredWorkoutSession[]>([])
  const [runs, setRuns] = useState<StoredRun[]>([])
  const [measurements, setMeasurements] = useState<StoredMeasurement[]>([])
  const [targetWeight, setTargetWeight] = useState('70')
  const [gymTarget, setGymTarget] = useState('4')
  const [runTarget, setRunTarget] = useState('3')

  const [workoutName, setWorkoutName] = useState('Push Day')
  const [duration, setDuration] = useState('60')
  const [workoutNotes, setWorkoutNotes] = useState('')
  const [draftExercises, setDraftExercises] = useState<ExerciseDraft[]>([])
  const [showPicker, setShowPicker] = useState(false)
  const [exerciseSearch, setExerciseSearch] = useState('')
  const [muscleFilter, setMuscleFilter] = useState('All')
  const [customExercise, setCustomExercise] = useState('')
  const [restSeconds, setRestSeconds] = useState(90)
  const [timer, setTimer] = useState(0)
  const [timerActive, setTimerActive] = useState(false)
  const [saving, setSaving] = useState(false)

  const [distance, setDistance] = useState('')
  const [runDuration, setRunDuration] = useState('')
  const [runNotes, setRunNotes] = useState('')
  const [measurementDate, setMeasurementDate] = useState(getTodayKey())
  const [weightKg, setWeightKg] = useState('')
  const [waist, setWaist] = useState('')
  const [chest, setChest] = useState('')
  const [arm, setArm] = useState('')
  const [hip, setHip] = useState('')
  const [measurementNotes, setMeasurementNotes] = useState('')

  const refresh = useCallback(async () => {
    const [s, r, m, goal] = await Promise.all([
      db.workoutSessions.orderBy('date').reverse().toArray(),
      db.runs.orderBy('date').reverse().toArray(),
      db.measurements.orderBy('date').reverse().toArray(),
      db.fitnessGoals.get('main'),
    ])
    setSessions(s); setRuns(r); setMeasurements(m)
    if (goal) {
      setTargetWeight(String(goal.targetWeightKg))
      setGymTarget(String(goal.weeklyGymSessions))
      setRunTarget(String(goal.weeklyRunningSessions))
    }
  }, [])

  useEffect(() => { void refresh() }, [refresh])
  useEffect(() => {
    if (!timerActive || timer <= 0) return
    const id = window.setInterval(() => setTimer(value => {
      if (value <= 1) { setTimerActive(false); return 0 }
      return value - 1
    }), 1000)
    return () => window.clearInterval(id)
  }, [timerActive, timer > 0])

  const filteredExercises = useMemo(() => exerciseLibrary.filter(item =>
    (muscleFilter === 'All' || item.muscleGroup === muscleFilter) &&
    `${item.name} ${item.muscleGroup} ${item.equipment}`.toLowerCase().includes(exerciseSearch.toLowerCase())
  ), [muscleFilter, exerciseSearch])

  const latestWeight = measurements[0]?.weightKg
  const firstWeight = measurements.length ? measurements[measurements.length - 1].weightKg : undefined
  const weightChange = latestWeight !== undefined && firstWeight !== undefined ? latestWeight - firstWeight : 0
  const weekStart = new Date()
  weekStart.setDate(weekStart.getDate() - 6)
  const weekKey = `${weekStart.getFullYear()}-${String(weekStart.getMonth() + 1).padStart(2, '0')}-${String(weekStart.getDate()).padStart(2, '0')}`
  const weeklyWorkouts = sessions.filter(item => item.date >= weekKey).length
  const weeklyRuns = runs.filter(item => item.date >= weekKey).length
  const totalKm = runs.reduce((sum, run) => sum + run.distanceKm, 0)
  const setCount = draftExercises.reduce((sum, item) => sum + item.sets.length, 0)
  const volume = draftExercises.reduce((sum, exercise) => sum + exercise.sets.reduce((inner, set) => inner + set.weightKg * set.reps, 0), 0)
  const completedSetCount = draftExercises.reduce((sum, exercise) => sum + exercise.sets.filter(set => set.completed).length, 0)

  function addExercise(id: string) {
    if (draftExercises.some(item => item.exerciseId === id)) return
    const exercise = makeExercise(id)
    if (exercise) setDraftExercises(items => [...items, exercise])
  }

  function loadTemplate(name: string) {
    setWorkoutName(name)
    setDraftExercises((templates[name] ?? []).map(id => makeExercise(id)).filter((item): item is ExerciseDraft => item !== null))
  }

  function updateSet(exerciseId: string, setId: string, patch: Partial<StoredWorkoutSet>) {
    setDraftExercises(items => items.map(exercise => exercise.id !== exerciseId ? exercise : {
      ...exercise,
      sets: exercise.sets.map(set => set.id !== setId ? set : { ...set, ...patch }),
    }))
  }

  function addSet(exerciseId: string) {
    setDraftExercises(items => items.map(exercise => exercise.id !== exerciseId ? exercise : {
      ...exercise, sets: [...exercise.sets, makeSet(exercise.sets.length + 1)],
    }))
  }

  function removeSet(exerciseId: string, setId: string) {
    setDraftExercises(items => items.map(exercise => exercise.id !== exerciseId ? exercise : {
      ...exercise,
      sets: exercise.sets.filter(set => set.id !== setId).map((set, index) => ({ ...set, setNumber: index + 1 })),
    }))
  }

  function moveExercise(index: number, direction: -1 | 1) {
    setDraftExercises(items => {
      const next = [...items]
      const target = index + direction
      if (target < 0 || target >= next.length) return items
      ;[next[index], next[target]] = [next[target], next[index]]
      return next
    })
  }

  async function finishWorkout(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!draftExercises.length) return
    setSaving(true)
    try {
      const finishedExercises = draftExercises.map(exercise => ({
        ...exercise,
        sets: exercise.sets.map((set, index) => ({ ...set, setNumber: index + 1 })),
      }))
      const totalVolumeKg = finishedExercises.reduce((sum, exercise) =>
        sum + exercise.sets.filter(set => set.completed).reduce((inner, set) => inner + set.weightKg * set.reps, 0), 0)
      const completedSets = finishedExercises.reduce((sum, exercise) => sum + exercise.sets.filter(set => set.completed).length, 0)
      await db.workoutSessions.add({
        id: crypto.randomUUID(), date: getTodayKey(), workoutName: workoutName.trim() || 'Gym session',
        durationMinutes: Math.max(1, Number(duration) || 1), exercises: finishedExercises,
        notes: workoutNotes.trim() || undefined, totalVolumeKg, completedSets,
      })
      setDraftExercises([]); setWorkoutNotes(''); setTimerActive(false); setTimer(0)
      await refresh()
    } finally { setSaving(false) }
  }

  async function saveRun(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (Number(distance) <= 0 || Number(runDuration) <= 0) return
    setSaving(true)
    try {
      await db.runs.add({ id: crypto.randomUUID(), date: getTodayKey(), distanceKm: Number(distance), durationMinutes: Number(runDuration), notes: runNotes.trim() || undefined })
      setDistance(''); setRunDuration(''); setRunNotes(''); await refresh()
    } finally { setSaving(false) }
  }

  async function saveMeasurement(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (Number(weightKg) <= 0) return
    setSaving(true)
    try {
      await db.measurements.add({
        id: crypto.randomUUID(), date: measurementDate, weightKg: Number(weightKg),
        waistCm: waist ? Number(waist) : undefined, chestCm: chest ? Number(chest) : undefined,
        armCm: arm ? Number(arm) : undefined, hipCm: hip ? Number(hip) : undefined,
        notes: measurementNotes.trim() || undefined,
      })
      setWaist(''); setChest(''); setArm(''); setHip(''); setMeasurementNotes(''); await refresh()
    } finally { setSaving(false) }
  }

  async function saveGoals(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    await db.fitnessGoals.put({ id: 'main', targetWeightKg: Number(targetWeight) || 0, weeklyGymSessions: Number(gymTarget) || 0, weeklyRunningSessions: Number(runTarget) || 0 })
    await refresh()
  }

  async function deleteSession(id: string) { await db.workoutSessions.delete(id); await refresh() }
  async function deleteRun(id: string) { await db.runs.delete(id); await refresh() }
  async function deleteMeasurement(id: string) { await db.measurements.delete(id); await refresh() }

  return (
    <div className="space-y-6">
      <header className="flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
        <div>
          <div className="mb-2 flex items-center gap-2 text-sm font-medium text-emerald-400"><Activity size={17} /> FITNESS WORKSPACE</div>
          <h2 className="text-3xl font-bold tracking-tight">Train with purpose.</h2>
          <p className="mt-2 text-sm text-zinc-500">Strength, endurance and body-composition progress in one place.</p>
        </div>
        <div className="flex items-center gap-2 text-xs text-zinc-500"><CalendarDays size={15} /> {new Date().toLocaleDateString('en-IN', { weekday: 'long', day: 'numeric', month: 'long' })}</div>
      </header>

      <section className="grid grid-cols-2 gap-3 xl:grid-cols-4">
        <Metric icon={Dumbbell} label="Gym sessions · 7 days" value={String(weeklyWorkouts)} detail={`Target ${gymTarget}/week`} />
        <Metric icon={Footprints} label="Runs · 7 days" value={String(weeklyRuns)} detail={`Target ${runTarget}/week`} />
        <Metric icon={Activity} label="Total distance" value={`${totalKm.toFixed(1)} km`} detail={`${runs.length} run records`} />
        <Metric icon={Scale} label="Latest weight" value={latestWeight ? `${latestWeight.toFixed(1)} kg` : '—'} detail={latestWeight ? `${weightChange > 0 ? '+' : ''}${weightChange.toFixed(1)} kg since first log` : 'Add your first measurement'} />
      </section>

      <section className={card}>
        <div className="mb-5 flex flex-wrap items-center justify-between gap-3">
          <div><h3 className="font-semibold">Fitness tracker</h3><p className="mt-1 text-xs text-zinc-500">Build complete workouts, log runs and record measurements.</p></div>
          <div className="flex rounded-xl bg-[#0b0e0c] p-1">
            {([{ id: 'workout', name: 'Workout' }, { id: 'running', name: 'Running' }, { id: 'body', name: 'Body' }] as const).map(item => (
              <button type="button" key={item.id} onClick={() => setTab(item.id)} className={`rounded-lg px-3 py-2 text-xs font-medium ${tab === item.id ? 'bg-emerald-400 text-black' : 'text-zinc-500 hover:text-white'}`}>{item.name}</button>
            ))}
          </div>
        </div>

        {tab === 'workout' && (
          <form onSubmit={finishWorkout} className="space-y-5">
            <div className="grid gap-3 sm:grid-cols-[1fr_150px]">
              <label><span className={label}>Workout name</span><input className={field} value={workoutName} onChange={event => setWorkoutName(event.target.value)} placeholder="Push Day, Pull Day..." /></label>
              <label><span className={label}>Duration (min)</span><input className={field} type="number" min="1" value={duration} onChange={event => setDuration(event.target.value)} /></label>
            </div>

            <div className="flex flex-wrap items-center gap-2">
              <span className="mr-1 text-xs text-zinc-500">Start with a template:</span>
              {Object.keys(templates).map(name => <button type="button" key={name} onClick={() => loadTemplate(name)} className="rounded-lg border border-white/10 px-3 py-2 text-xs text-zinc-300 hover:border-emerald-400/40 hover:text-emerald-300">{name}</button>)}
              <button type="button" onClick={() => { setWorkoutName('Custom Workout'); setDraftExercises([]) }} className="rounded-lg border border-white/10 px-3 py-2 text-xs text-zinc-400 hover:text-white">Start blank</button>
            </div>

            <div className="flex flex-wrap items-center justify-between gap-3 rounded-xl bg-[#0b0e0c] p-3">
              <div className="flex flex-wrap gap-4 text-xs text-zinc-400">
                <span><strong className="text-white">{draftExercises.length}</strong> exercises</span>
                <span><strong className="text-white">{setCount}</strong> sets</span>
                <span><strong className="text-white">{completedSetCount}</strong> completed</span>
                <span><strong className="text-emerald-400">{Math.round(volume).toLocaleString('en-IN')}</strong> kg planned volume</span>
              </div>
              <button type="button" onClick={() => setShowPicker(value => !value)} className="inline-flex items-center gap-2 rounded-lg bg-emerald-400 px-3 py-2 text-xs font-semibold text-black"><Plus size={15} /> Add exercises</button>
            </div>

            {showPicker && (
              <div className="rounded-xl border border-emerald-400/20 bg-[#0d110e] p-4">
                <div className="mb-3 flex items-center justify-between"><div><h4 className="text-sm font-semibold">Exercise library</h4><p className="mt-1 text-xs text-zinc-500">Select multiple exercises. Selected exercises are added to your workout.</p></div><button type="button" onClick={() => setShowPicker(false)} className="text-zinc-500 hover:text-white"><X size={18} /></button></div>
                <div className="relative mb-3"><Search size={16} className="absolute left-3 top-3 text-zinc-500" /><input className={`${field} pl-9`} value={exerciseSearch} onChange={event => setExerciseSearch(event.target.value)} placeholder="Search exercise or equipment..." /></div>
                <div className="mb-3 flex flex-wrap gap-2">{muscleGroups.map(group => <button type="button" key={group} onClick={() => setMuscleFilter(group)} className={`rounded-full px-3 py-1.5 text-[11px] ${muscleFilter === group ? 'bg-emerald-400 text-black' : 'bg-white/[0.05] text-zinc-400 hover:text-white'}`}>{group}</button>)}</div>
                <div className="grid max-h-64 gap-2 overflow-y-auto sm:grid-cols-2">
                  {filteredExercises.map(exercise => {
                    const selected = draftExercises.some(item => item.exerciseId === exercise.id)
                    return <button type="button" key={exercise.id} disabled={selected} onClick={() => addExercise(exercise.id)} className={`flex items-center justify-between gap-3 rounded-lg border p-3 text-left text-xs ${selected ? 'border-emerald-400/20 bg-emerald-400/[0.06] text-emerald-300 opacity-70' : 'border-white/[0.06] bg-white/[0.02] text-zinc-200 hover:border-emerald-400/30'}`}><span><strong className="block">{exercise.name}</strong><span className="mt-1 block text-zinc-500">{exercise.muscleGroup} · {exercise.equipment}</span></span>{selected ? <Check size={16} /> : <Plus size={16} />}</button>
                  })}
                  {filteredExercises.length === 0 && <p className="py-4 text-xs text-zinc-500">No matching exercises.</p>}
                </div>
                <div className="mt-4 flex flex-wrap items-end gap-2 border-t border-white/[0.06] pt-3">
                  <label className="min-w-0 flex-1"><span className={label}>Custom exercise name</span><input className={field} value={customExercise} onChange={event => setCustomExercise(event.target.value)} placeholder="Add an exercise not listed..." /></label>
                  <button type="button" disabled={!customExercise.trim()} onClick={() => {
                    const name = customExercise.trim()
                    const id = `custom-${name.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`
                    if (!draftExercises.some(item => item.exerciseId === id)) setDraftExercises(items => [...items, { id: crypto.randomUUID(), exerciseId: id, exerciseName: name, muscleGroup: 'Custom', equipment: 'Custom', sets: [makeSet(1), makeSet(2), makeSet(3)] }])
                    setCustomExercise('')
                  }} className="rounded-xl bg-white/10 px-4 py-3 text-xs font-semibold text-white disabled:opacity-40">Add custom</button>
                </div>
              </div>
            )}

            {draftExercises.length === 0 ? (
              <div className="rounded-xl border border-dashed border-white/10 px-5 py-10 text-center"><Dumbbell size={26} className="mx-auto mb-3 text-zinc-600" /><p className="text-sm font-medium text-zinc-300">Your workout is empty</p><p className="mt-1 text-xs text-zinc-500">Choose a template or add multiple exercises from the library.</p></div>
            ) : (
              <div className="space-y-3">
                {draftExercises.map((exercise, index) => (
                  <div key={exercise.id} className="overflow-hidden rounded-xl border border-white/[0.07] bg-[#0d110e]">
                    <div className="flex items-center justify-between gap-3 border-b border-white/[0.06] px-4 py-3">
                      <div className="min-w-0"><p className="truncate text-sm font-semibold">{index + 1}. {exercise.exerciseName}</p><p className="mt-1 text-[11px] text-zinc-500">{exercise.muscleGroup} · {exercise.equipment}</p></div>
                      <div className="flex shrink-0 items-center gap-1">
                        <button type="button" aria-label="Move exercise up" disabled={index === 0} onClick={() => moveExercise(index, -1)} className="rounded-md p-2 text-zinc-500 hover:text-white disabled:opacity-20"><ChevronUp size={16} /></button>
                        <button type="button" aria-label="Move exercise down" disabled={index === draftExercises.length - 1} onClick={() => moveExercise(index, 1)} className="rounded-md p-2 text-zinc-500 hover:text-white disabled:opacity-20"><ChevronDown size={16} /></button>
                        <button type="button" aria-label="Remove exercise" onClick={() => setDraftExercises(items => items.filter(item => item.id !== exercise.id))} className="rounded-md p-2 text-zinc-500 hover:text-red-400"><Trash2 size={15} /></button>
                      </div>
                    </div>
                    <div className="p-3">
                      <div className="mb-2 grid grid-cols-[36px_1fr_1fr_36px] gap-2 px-1 text-[10px] uppercase tracking-wider text-zinc-600"><span>Set</span><span>Weight · kg</span><span>Reps</span><span>Done</span></div>
                      {exercise.sets.map((set, setIndex) => (
                        <div key={set.id} className={`mb-2 grid grid-cols-[36px_1fr_1fr_36px] items-center gap-2 rounded-lg p-1 ${set.completed ? 'bg-emerald-400/[0.06]' : ''}`}>
                          <span className="text-center text-xs text-zinc-500">{setIndex + 1}</span>
                          <input aria-label={`${exercise.exerciseName} set ${setIndex + 1} weight in kg`} className={field} type="number" min="0" step="0.5" value={set.weightKg} onChange={event => updateSet(exercise.id, set.id, { weightKg: Math.max(0, Number(event.target.value)) })} />
                          <input aria-label={`${exercise.exerciseName} set ${setIndex + 1} reps`} className={field} type="number" min="0" value={set.reps} onChange={event => updateSet(exercise.id, set.id, { reps: Math.max(0, Number(event.target.value)) })} />
                          <button type="button" aria-label={set.completed ? 'Mark set incomplete' : 'Mark set complete'} onClick={() => updateSet(exercise.id, set.id, { completed: !set.completed })} className={`mx-auto flex h-8 w-8 items-center justify-center rounded-lg border ${set.completed ? 'border-emerald-400 bg-emerald-400 text-black' : 'border-white/10 text-zinc-500 hover:border-emerald-400/40'}`}><Check size={15} /></button>
                        </div>
                      ))}
                      <div className="mt-2 flex flex-wrap items-center justify-between gap-2">
                        <button type="button" onClick={() => addSet(exercise.id)} className="inline-flex items-center gap-1 text-xs font-medium text-emerald-400 hover:text-emerald-300"><Plus size={14} /> Add set</button>
                        <button type="button" onClick={() => removeSet(exercise.id, exercise.sets[exercise.sets.length - 1]?.id ?? '')} disabled={exercise.sets.length <= 1} className="text-[11px] text-zinc-600 hover:text-red-400 disabled:opacity-30">Remove last set</button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}

            <div className="grid gap-3 sm:grid-cols-[1fr_auto]">
              <label><span className={label}>Workout notes (optional)</span><input className={field} value={workoutNotes} onChange={event => setWorkoutNotes(event.target.value)} placeholder="Energy, form, personal bests..." /></label>
              <div className="flex items-end"><button type="submit" disabled={saving || draftExercises.length === 0} className="flex w-full items-center justify-center gap-2 rounded-xl bg-emerald-400 px-5 py-3 text-sm font-semibold text-black disabled:opacity-40 sm:w-auto"><Trophy size={16} /> {saving ? 'Saving...' : 'Finish workout'}</button></div>
            </div>
          </form>
        )}

        {tab === 'running' && (
          <form onSubmit={saveRun} className="grid gap-4 sm:grid-cols-2">
            <label><span className={label}>Distance (km)</span><input required className={field} type="number" min="0.1" step="0.01" value={distance} onChange={event => setDistance(event.target.value)} placeholder="e.g. 3.5" /></label>
            <label><span className={label}>Duration (minutes)</span><input required className={field} type="number" min="1" value={runDuration} onChange={event => setRunDuration(event.target.value)} placeholder="e.g. 30" /></label>
            <label className="sm:col-span-2"><span className={label}>Notes (optional)</span><input className={field} value={runNotes} onChange={event => setRunNotes(event.target.value)} /></label>
            {Number(distance) > 0 && Number(runDuration) > 0 && <p className="rounded-xl bg-[#0b0e0c] p-3 text-sm text-zinc-400 sm:col-span-2">Estimated pace: <strong className="text-emerald-400">{(Number(runDuration) / Number(distance)).toFixed(2)} min/km</strong></p>}
            <div className="sm:col-span-2 flex justify-end"><button disabled={saving} className="rounded-xl bg-emerald-400 px-5 py-3 text-sm font-semibold text-black disabled:opacity-40">Save run</button></div>
          </form>
        )}

        {tab === 'body' && (
          <form onSubmit={saveMeasurement} className="grid gap-4 sm:grid-cols-2">
            <label><span className={label}>Date</span><input required className={field} type="date" value={measurementDate} onChange={event => setMeasurementDate(event.target.value)} /></label>
            <label><span className={label}>Weight (kg)</span><input required className={field} type="number" min="1" step="0.1" value={weightKg} onChange={event => setWeightKg(event.target.value)} /></label>
            <label><span className={label}>Waist (cm)</span><input className={field} type="number" min="1" step="0.1" value={waist} onChange={event => setWaist(event.target.value)} /></label>
            <label><span className={label}>Chest (cm)</span><input className={field} type="number" min="1" step="0.1" value={chest} onChange={event => setChest(event.target.value)} /></label>
            <label><span className={label}>Arm (cm)</span><input className={field} type="number" min="1" step="0.1" value={arm} onChange={event => setArm(event.target.value)} /></label>
            <label><span className={label}>Hip (cm)</span><input className={field} type="number" min="1" step="0.1" value={hip} onChange={event => setHip(event.target.value)} /></label>
            <label className="sm:col-span-2"><span className={label}>Notes</span><input className={field} value={measurementNotes} onChange={event => setMeasurementNotes(event.target.value)} /></label>
            <div className="sm:col-span-2 flex justify-end"><button disabled={saving} className="rounded-xl bg-emerald-400 px-5 py-3 text-sm font-semibold text-black disabled:opacity-40">Save measurements</button></div>
          </form>
        )}
      </section>

      {tab === 'workout' && (
        <section className="grid gap-5 xl:grid-cols-[1fr_300px]">
          <div className={card}>
            <div className="mb-4 flex items-center justify-between"><div><h3 className="font-semibold">Workout history</h3><p className="mt-1 text-xs text-zinc-500">Your completed training sessions.</p></div><span className="text-xs text-zinc-600">{sessions.length} sessions</span></div>
            {sessions.length === 0 ? <p className="py-6 text-sm text-zinc-500">No completed workouts yet. Your saved sessions will appear here.</p> : <div className="space-y-3">{sessions.slice(0, 10).map(session => <div key={session.id} className="rounded-xl border border-white/[0.06] bg-[#0d110e] p-4"><div className="flex items-start justify-between gap-3"><div><p className="font-semibold">{session.workoutName}</p><p className="mt-1 text-xs text-zinc-500">{dateLabel(session.date)} · {session.durationMinutes} min · {session.exercises.length} exercises · {session.completedSets} completed sets</p></div><button type="button" onClick={() => void deleteSession(session.id)} aria-label="Delete workout session" className="text-zinc-600 hover:text-red-400"><Trash2 size={15} /></button></div><div className="mt-3 flex flex-wrap gap-1.5">{session.exercises.map(exercise => <span key={exercise.id} className="rounded-md bg-white/[0.05] px-2 py-1 text-[10px] text-zinc-400">{exercise.exerciseName}</span>)}</div><p className="mt-3 text-xs text-emerald-400">Completed volume: {Math.round(session.totalVolumeKg).toLocaleString('en-IN')} kg</p>{session.notes && <p className="mt-1 text-xs text-zinc-500">{session.notes}</p>}</div>)}</div>}
          </div>
          <div className={card}>
            <div className="mb-4 flex items-center gap-2"><TimerReset size={18} className="text-emerald-400" /><h3 className="font-semibold">Rest timer</h3></div>
            <p className="mb-3 text-center text-4xl font-bold tabular-nums">{`${Math.floor(timer / 60).toString().padStart(2, '0')}:${(timer % 60).toString().padStart(2, '0')}`}</p>
            <div className="mb-3 grid grid-cols-3 gap-2">{[60, 90, 120].map(seconds => <button type="button" key={seconds} onClick={() => { setRestSeconds(seconds); setTimer(seconds); setTimerActive(false) }} className={`rounded-lg py-2 text-xs ${restSeconds === seconds ? 'bg-emerald-400 text-black' : 'bg-white/[0.05] text-zinc-400'}`}>{seconds}s</button>)}</div>
            <div className="grid grid-cols-2 gap-2"><button type="button" onClick={() => { if (timer <= 0) setTimer(restSeconds); setTimerActive(true) }} className="rounded-lg bg-emerald-400 py-2.5 text-xs font-semibold text-black">Start</button><button type="button" onClick={() => { setTimer(0); setTimerActive(false) }} className="rounded-lg bg-white/[0.06] py-2.5 text-xs text-zinc-300">Reset</button></div>
          </div>
        </section>
      )}

      {tab !== 'workout' && (
        <section className="grid gap-5 xl:grid-cols-2">
          <History title={tab === 'running' ? 'Running history' : 'Body measurement history'} count={tab === 'running' ? runs.length : measurements.length}>
            {tab === 'running' ? runs.slice(0, 10).map(item => <div key={item.id} className="flex justify-between gap-3 border-t border-white/[0.06] py-3"><div><p className="text-sm font-medium">{item.distanceKm.toFixed(2)} km run</p><p className="mt-1 text-xs text-zinc-500">{dateLabel(item.date)} · {item.durationMinutes} min · {(item.durationMinutes / item.distanceKm).toFixed(2)} min/km</p></div><button type="button" onClick={() => void deleteRun(item.id)} className="text-zinc-600 hover:text-red-400"><Trash2 size={15} /></button></div>) : measurements.slice(0, 10).map(item => <div key={item.id} className="flex justify-between gap-3 border-t border-white/[0.06] py-3"><div><p className="text-sm font-medium">{item.weightKg.toFixed(1)} kg · {dateLabel(item.date)}</p><p className="mt-1 text-xs text-zinc-500">Waist {item.waistCm ?? '—'} · Chest {item.chestCm ?? '—'} · Arm {item.armCm ?? '—'} cm</p></div><button type="button" onClick={() => void deleteMeasurement(item.id)} className="text-zinc-600 hover:text-red-400"><Trash2 size={15} /></button></div>)}
          </History>
          <div className={card}>
            <div className="mb-4 flex items-center gap-2"><Target size={18} className="text-emerald-400" /><h3 className="font-semibold">Fitness targets</h3></div>
            <form onSubmit={saveGoals} className="space-y-3">
              <Goal label="Target weight (kg)" value={targetWeight} onChange={setTargetWeight} />
              <Goal label="Gym sessions per week" value={gymTarget} onChange={setGymTarget} />
              <Goal label="Running sessions per week" value={runTarget} onChange={setRunTarget} />
              <button className="w-full rounded-xl border border-emerald-400/20 bg-emerald-400/10 py-3 text-sm font-semibold text-emerald-400">Save targets</button>
            </form>
            <div className="mt-5 space-y-3"><TargetBar label="Gym" value={weeklyWorkouts} goal={Number(gymTarget)} /><TargetBar label="Running" value={weeklyRuns} goal={Number(runTarget)} /></div>
          </div>
        </section>
      )}

      <p className="text-center text-[11px] text-zinc-600">Workout, running and measurement records are stored locally on this device. Export/backup will be added to LifeOS core settings.</p>
    </div>
  )
}

function dateLabel(date: string) { return new Date(`${date}T12:00:00`).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' }) }
function Metric({ icon: Icon, label: title, value, detail }: { icon: typeof Activity; label: string; value: string; detail: string }) { return <div className={card}><div className="mb-3 flex items-center justify-between"><span className="text-xs text-zinc-500">{title}</span><Icon size={18} className="text-emerald-400" /></div><p className="text-2xl font-bold">{value}</p><p className="mt-1 text-[11px] text-zinc-600">{detail}</p></div> }
function Goal({ label: title, value, onChange }: { label: string; value: string; onChange: (value: string) => void }) { return <label className="block"><span className={label}>{title}</span><input className={field} type="number" min="0" value={value} onChange={event => onChange(event.target.value)} /></label> }
function TargetBar({ label: title, value, goal }: { label: string; value: number; goal: number }) { const percent = goal > 0 ? Math.min(100, value / goal * 100) : 0; return <div><div className="mb-1 flex justify-between text-xs"><span className="text-zinc-400">{title}</span><span className="text-zinc-500">{value}/{goal}</span></div><div className="h-1.5 overflow-hidden rounded-full bg-zinc-800"><div className="h-full rounded-full bg-emerald-400" style={{ width: `${percent}%` }} /></div></div> }
function History({ title, count, children }: { title: string; count: number; children: ReactNode }) { return <div className={card}><div className="mb-3 flex items-center justify-between"><h3 className="font-semibold">{title}</h3><span className="text-xs text-zinc-600">{count} records</span></div>{count === 0 ? <p className="py-5 text-sm text-zinc-500">No records yet.</p> : children}</div> }

export default Fitness
'@ | Set-Content -Encoding utf8 ".\src\modules\fitness\Fitness.tsx"

Write-Host ""
Write-Host "Fitness Pro installed. Existing fitness records remain in their original stores; new multi-exercise sessions use workoutSessions." -ForegroundColor Green
Write-Host "Run: npm.cmd run build" -ForegroundColor Cyan
