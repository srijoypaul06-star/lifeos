import { useCallback, useEffect, useMemo, useState, type FormEvent, type ReactNode } from 'react'
import { Apple, CalendarDays, Flame, Plus, Search, Target, Trash2, Utensils } from 'lucide-react'
import { db, getTodayKey, type StoredNutritionGoal, type StoredNutritionMeal } from '../../database/db'
import { indianFoods } from './data'

type MealType = StoredNutritionMeal['mealType']
const mealTypes: MealType[] = ['Breakfast', 'Lunch', 'Snacks', 'Dinner']
const card = 'rounded-2xl border border-white/[0.07] bg-[#111412] p-5'
const input = 'w-full rounded-xl border border-white/10 bg-[#0c100d] px-3 py-3 text-sm text-zinc-100 outline-none focus:border-emerald-400/50'
const label = 'mb-1.5 block text-xs font-medium text-zinc-400'

function Nutrition() {
  const [date, setDate] = useState(getTodayKey())
  const [meals, setMeals] = useState<StoredNutritionMeal[]>([])
  const [goals, setGoals] = useState<StoredNutritionGoal>({ id: 'main', calories: 2200, protein: 130, carbs: 250, fat: 70 })
  const [mealType, setMealType] = useState<MealType>('Breakfast')
  const [foodId, setFoodId] = useState(indianFoods[0].id)
  const [quantity, setQuantity] = useState('100')
  const [search, setSearch] = useState('')
  const [customName, setCustomName] = useState('')
  const [customCalories, setCustomCalories] = useState('')
  const [customProtein, setCustomProtein] = useState('')
  const [customCarbs, setCustomCarbs] = useState('')
  const [customFat, setCustomFat] = useState('')
  const [mode, setMode] = useState<'database' | 'custom'>('database')
  const [saving, setSaving] = useState(false)

  const refresh = useCallback(async () => {
    const [entries, savedGoals] = await Promise.all([
      db.nutritionMeals.where('date').equals(date).toArray(),
      db.nutritionGoals.get('main'),
    ])
    setMeals(entries)
    if (savedGoals) setGoals(savedGoals)
  }, [date])

  useEffect(() => { void refresh() }, [refresh])

  const totals = useMemo(() => meals.reduce((sum, item) => ({
    calories: sum.calories + item.calories,
    protein: sum.protein + item.protein,
    carbs: sum.carbs + item.carbs,
    fat: sum.fat + item.fat,
  }), { calories: 0, protein: 0, carbs: 0, fat: 0 }), [meals])

  const filteredFoods = indianFoods.filter(food =>
    `${food.name} ${food.category}`.toLowerCase().includes(search.toLowerCase())
  )
  const selectedFood = indianFoods.find(food => food.id === foodId)

  async function addFood(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const grams = Number(quantity)
    if (!Number.isFinite(grams) || grams <= 0) return
    let name = ''
    let calories = 0
    let protein = 0
    let carbs = 0
    let fat = 0
    if (mode === 'database') {
      if (!selectedFood) return
      name = selectedFood.name
      calories = selectedFood.calories * grams / 100
      protein = selectedFood.protein * grams / 100
      carbs = selectedFood.carbs * grams / 100
      fat = selectedFood.fat * grams / 100
    } else {
      if (!customName.trim()) return
      name = customName.trim()
      calories = Number(customCalories) * grams / 100
      protein = Number(customProtein || 0) * grams / 100
      carbs = Number(customCarbs || 0) * grams / 100
      fat = Number(customFat || 0) * grams / 100
      if (![calories, protein, carbs, fat].every(value => Number.isFinite(value) && value >= 0)) return
    }
    setSaving(true)
    try {
      await db.nutritionMeals.add({
        id: crypto.randomUUID(), date, mealType, foodName: name,
        quantityGrams: grams, calories: round(calories), protein: round(protein),
        carbs: round(carbs), fat: round(fat),
      })
      setQuantity('100')
      setCustomName(''); setCustomCalories(''); setCustomProtein(''); setCustomCarbs(''); setCustomFat('')
      await refresh()
    } finally { setSaving(false) }
  }

  async function saveGoals(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    await db.nutritionGoals.put(goals)
    await refresh()
  }

  async function removeMeal(id: string) {
    await db.nutritionMeals.delete(id)
    await refresh()
  }

  return (
    <div className="space-y-6">
      <header className="flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
        <div>
          <div className="mb-2 flex items-center gap-2 text-sm font-medium text-emerald-400"><Apple size={17} /> NUTRITION WORKSPACE</div>
          <h2 className="text-3xl font-bold tracking-tight">Fuel your progress.</h2>
          <p className="mt-2 text-sm text-zinc-500">Track meals, calories and macros with an Indian food starter library.</p>
        </div>
        <label className="flex items-center gap-2 text-xs text-zinc-500"><CalendarDays size={15} /><input aria-label="Nutrition date" className={`${input} w-auto`} type="date" value={date} onChange={event => setDate(event.target.value)} /></label>
      </header>

      <section className="grid grid-cols-2 gap-3 xl:grid-cols-4">
        <Metric icon={Flame} title="Calories" value={`${Math.round(totals.calories)}`} goal={goals.calories} unit="kcal" />
        <Metric icon={Target} title="Protein" value={totals.protein.toFixed(1)} goal={goals.protein} unit="g" />
        <Metric icon={Apple} title="Carbs" value={totals.carbs.toFixed(1)} goal={goals.carbs} unit="g" />
        <Metric icon={Utensils} title="Fat" value={totals.fat.toFixed(1)} goal={goals.fat} unit="g" />
      </section>

      <section className="grid gap-5 xl:grid-cols-[1.4fr_1fr]">
        <div className={card}>
          <div className="mb-5"><h3 className="font-semibold">Add food</h3><p className="mt-1 text-xs text-zinc-500">Nutrition estimates are calculated from a 100 g reference.</p></div>
          <form onSubmit={addFood} className="space-y-4">
            <div className="flex gap-2">
              <button type="button" onClick={() => setMode('database')} className={`rounded-lg px-3 py-2 text-xs ${mode === 'database' ? 'bg-emerald-400 text-black' : 'bg-[#0b0e0c] text-zinc-400'}`}>Food database</button>
              <button type="button" onClick={() => setMode('custom')} className={`rounded-lg px-3 py-2 text-xs ${mode === 'custom' ? 'bg-emerald-400 text-black' : 'bg-[#0b0e0c] text-zinc-400'}`}>Custom food</button>
            </div>
            <Field label="Meal"><select className={input} value={mealType} onChange={event => setMealType(event.target.value as MealType)}>{mealTypes.map(type => <option key={type}>{type}</option>)}</select></Field>
            {mode === 'database' ? <>
              <Field label="Search food"><div className="relative"><Search size={16} className="absolute left-3 top-3.5 text-zinc-500" /><input className={`${input} pl-9`} value={search} onChange={event => setSearch(event.target.value)} placeholder="Search rice, dal, paneer..." /></div></Field>
              <Field label="Select food"><select className={input} value={foodId} onChange={event => setFoodId(event.target.value)}>{filteredFoods.map(food => <option key={food.id} value={food.id}>{food.name} Â· {food.category}</option>)}</select></Field>
              {selectedFood && <div className="grid grid-cols-4 gap-2 rounded-xl bg-[#0b0e0c] p-3 text-center">{[['kcal', selectedFood.calories], ['Protein', selectedFood.protein], ['Carbs', selectedFood.carbs], ['Fat', selectedFood.fat]].map(([name, value]) => <div key={String(name)}><p className="text-[10px] text-zinc-500">{name}</p><p className="mt-1 text-sm font-semibold">{Number(value).toFixed(1)}</p></div>)}</div>}
            </> : <>
              <Field label="Food name"><input required className={input} value={customName} onChange={event => setCustomName(event.target.value)} placeholder="e.g. Homemade vegetable pulao" /></Field>
              <div className="grid grid-cols-2 gap-3">
                <Field label="Calories / 100 g"><input required className={input} type="number" min="0" step="0.1" value={customCalories} onChange={event => setCustomCalories(event.target.value)} /></Field>
                <Field label="Protein / 100 g"><input className={input} type="number" min="0" step="0.1" value={customProtein} onChange={event => setCustomProtein(event.target.value)} /></Field>
                <Field label="Carbs / 100 g"><input className={input} type="number" min="0" step="0.1" value={customCarbs} onChange={event => setCustomCarbs(event.target.value)} /></Field>
                <Field label="Fat / 100 g"><input className={input} type="number" min="0" step="0.1" value={customFat} onChange={event => setCustomFat(event.target.value)} /></Field>
              </div>
            </>}
            <Field label="Quantity (grams)"><input required className={input} type="number" min="1" step="1" value={quantity} onChange={event => setQuantity(event.target.value)} /></Field>
            <button disabled={saving} className="flex w-full items-center justify-center gap-2 rounded-xl bg-emerald-400 py-3 text-sm font-semibold text-black disabled:opacity-50"><Plus size={16} /> Add to {mealType}</button>
          </form>
        </div>

        <div className={card}>
          <div className="mb-5 flex items-center gap-2"><Target size={18} className="text-emerald-400" /><h3 className="font-semibold">Daily targets</h3></div>
          <form onSubmit={saveGoals} className="space-y-3">
            <GoalField label="Calories (kcal)" value={goals.calories} onChange={value => setGoals(current => ({ ...current, calories: value }))} />
            <GoalField label="Protein (g)" value={goals.protein} onChange={value => setGoals(current => ({ ...current, protein: value }))} />
            <GoalField label="Carbs (g)" value={goals.carbs} onChange={value => setGoals(current => ({ ...current, carbs: value }))} />
            <GoalField label="Fat (g)" value={goals.fat} onChange={value => setGoals(current => ({ ...current, fat: value }))} />
            <button className="w-full rounded-xl border border-emerald-400/20 bg-emerald-400/10 py-3 text-sm font-semibold text-emerald-400">Save nutrition targets</button>
          </form>
          <div className="mt-5 space-y-4">
            <MacroBar label="Calories" value={totals.calories} goal={goals.calories} color="bg-orange-400" />
            <MacroBar label="Protein" value={totals.protein} goal={goals.protein} color="bg-emerald-400" />
            <MacroBar label="Carbs" value={totals.carbs} goal={goals.carbs} color="bg-sky-400" />
            <MacroBar label="Fat" value={totals.fat} goal={goals.fat} color="bg-violet-400" />
          </div>
        </div>
      </section>

      <section className={card}>
        <div className="mb-4 flex items-center justify-between"><div><h3 className="font-semibold">Food diary</h3><p className="mt-1 text-xs text-zinc-500">{date} Â· {meals.length} entries</p></div><span className="text-sm font-semibold text-emerald-400">{Math.round(totals.calories)} kcal</span></div>
        {mealTypes.map(type => {
          const entries = meals.filter(item => item.mealType === type)
          if (!entries.length) return null
          return <div key={type} className="mb-5 last:mb-0"><h4 className="mb-2 text-xs font-semibold uppercase tracking-wider text-zinc-500">{type}</h4>{entries.map(item => <div key={item.id} className="flex items-center justify-between gap-3 border-t border-white/[0.06] py-3"><div className="min-w-0"><p className="truncate text-sm font-medium">{item.foodName}</p><p className="mt-1 text-xs text-zinc-500">{item.quantityGrams} g Â· P {item.protein.toFixed(1)} g Â· C {item.carbs.toFixed(1)} g Â· F {item.fat.toFixed(1)} g</p></div><div className="flex shrink-0 items-center gap-3"><span className="text-sm font-semibold">{Math.round(item.calories)} kcal</span><button onClick={() => void removeMeal(item.id)} aria-label={`Delete ${item.foodName}`} className="text-zinc-600 hover:text-red-400"><Trash2 size={15} /></button></div></div>)}</div>
        })}
        {meals.length === 0 && <div className="py-8 text-center"><Utensils className="mx-auto mb-3 text-zinc-600" size={24} /><p className="text-sm text-zinc-400">No meals logged for this date.</p><p className="mt-1 text-xs text-zinc-600">Add your first food entry above.</p></div>}
      </section>
      <p className="text-center text-[11px] text-zinc-600">Food values are approximate reference estimates. Home-cooked recipes vary with ingredients, oil and portion size. Data is stored locally in this browser.</p>
    </div>
  )
}

function round(value: number) { return Math.round(value * 10) / 10 }
function Field({ label: fieldLabel, children }: { label: string; children: ReactNode }) { return <label className="block"><span className={label}>{fieldLabel}</span>{children}</label> }
function Metric({ icon: Icon, title, value, goal, unit }: { icon: typeof Flame; title: string; value: string; goal: number; unit: string }) {
  const numeric = Number(value)
  const percent = goal > 0 ? Math.min(100, numeric / goal * 100) : 0
  return <div className={card}><div className="mb-3 flex items-center justify-between"><span className="text-xs text-zinc-500">{title}</span><Icon size={18} className="text-emerald-400" /></div><p className="text-2xl font-bold">{value}<span className="ml-1 text-xs font-normal text-zinc-500">{unit}</span></p><p className="mt-1 text-[11px] text-zinc-600">Target {goal} {unit}</p><div className="mt-3 h-1.5 overflow-hidden rounded-full bg-zinc-800"><div className="h-full rounded-full bg-emerald-400" style={{ width: `${percent}%` }} /></div></div>
}
function GoalField({ label: fieldLabel, value, onChange }: { label: string; value: number; onChange: (value: number) => void }) { return <label className="block"><span className={label}>{fieldLabel}</span><input className={input} type="number" min="0" step="1" value={value} onChange={event => onChange(Number(event.target.value))} /></label> }
function MacroBar({ label: barLabel, value, goal, color }: { label: string; value: number; goal: number; color: string }) { const percent = goal > 0 ? Math.min(100, value / goal * 100) : 0; return <div><div className="mb-1 flex justify-between text-xs"><span className="text-zinc-400">{barLabel}</span><span className="text-zinc-500">{Math.round(value)} / {goal}</span></div><div className="h-1.5 overflow-hidden rounded-full bg-zinc-800"><div className={`h-full rounded-full ${color}`} style={{ width: `${percent}%` }} /></div></div> }

export default Nutrition
