import type { FoodItem } from './types'

// Approximate values per 100 g of edible food, unless noted in the name.
// Use product labels or weighed recipes for more accurate tracking.
export const indianFoods: FoodItem[] = [
  { id: 'rice-cooked', name: 'Rice, cooked', category: 'Grains', servingUnit: 'g', calories: 130, protein: 2.7, carbs: 28.2, fat: 0.3 },
  { id: 'roti', name: 'Whole-wheat roti', category: 'Grains', servingUnit: 'g', calories: 297, protein: 9.8, carbs: 46.4, fat: 7.5 },
  { id: 'oats', name: 'Oats, dry', category: 'Grains', servingUnit: 'g', calories: 389, protein: 16.9, carbs: 66.3, fat: 6.9 },
  { id: 'poha', name: 'Poha, cooked', category: 'Grains', servingUnit: 'g', calories: 130, protein: 2.5, carbs: 24, fat: 3 },
  { id: 'idli', name: 'Idli', category: 'Grains', servingUnit: 'g', calories: 146, protein: 4.5, carbs: 29, fat: 0.7 },
  { id: 'dosa', name: 'Plain dosa', category: 'Grains', servingUnit: 'g', calories: 168, protein: 4, carbs: 29, fat: 3.5 },
  { id: 'moong-dal', name: 'Green moong dal, cooked', category: 'Pulses', servingUnit: 'g', calories: 105, protein: 7, carbs: 19, fat: 0.4 },
  { id: 'masoor-dal', name: 'Masoor dal, cooked', category: 'Pulses', servingUnit: 'g', calories: 116, protein: 9, carbs: 20, fat: 0.4 },
  { id: 'chana', name: 'Chickpeas, boiled', category: 'Pulses', servingUnit: 'g', calories: 164, protein: 8.9, carbs: 27.4, fat: 2.6 },
  { id: 'rajma', name: 'Rajma, boiled', category: 'Pulses', servingUnit: 'g', calories: 127, protein: 8.7, carbs: 22.8, fat: 0.5 },
  { id: 'paneer', name: 'Paneer', category: 'Dairy', servingUnit: 'g', calories: 265, protein: 18.3, carbs: 1.2, fat: 20.8 },
  { id: 'curd', name: 'Plain curd', category: 'Dairy', servingUnit: 'g', calories: 61, protein: 3.5, carbs: 4.7, fat: 3.3 },
  { id: 'greek-yogurt', name: 'Plain Greek yogurt', category: 'Dairy', servingUnit: 'g', calories: 97, protein: 9, carbs: 3.6, fat: 5 },
  { id: 'milk', name: 'Whole milk', category: 'Dairy', servingUnit: 'g', calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3 },
  { id: 'egg', name: 'Whole egg, cooked', category: 'Protein', servingUnit: 'g', calories: 155, protein: 13, carbs: 1.1, fat: 11 },
  { id: 'chicken', name: 'Chicken breast, cooked', category: 'Protein', servingUnit: 'g', calories: 165, protein: 31, carbs: 0, fat: 3.6 },
  { id: 'banana', name: 'Banana', category: 'Fruit', servingUnit: 'g', calories: 89, protein: 1.1, carbs: 22.8, fat: 0.3 },
  { id: 'apple', name: 'Apple', category: 'Fruit', servingUnit: 'g', calories: 52, protein: 0.3, carbs: 13.8, fat: 0.2 },
  { id: 'almonds', name: 'Almonds', category: 'Nuts & seeds', servingUnit: 'g', calories: 579, protein: 21.2, carbs: 21.6, fat: 49.9 },
  { id: 'peanuts', name: 'Peanuts', category: 'Nuts & seeds', servingUnit: 'g', calories: 567, protein: 25.8, carbs: 16.1, fat: 49.2 },
  { id: 'mixed-vegetables', name: 'Mixed vegetables, cooked', category: 'Vegetables', servingUnit: 'g', calories: 65, protein: 2.5, carbs: 11, fat: 1.5 },
  { id: 'potato', name: 'Potato, boiled', category: 'Vegetables', servingUnit: 'g', calories: 87, protein: 1.9, carbs: 20.1, fat: 0.1 },
  { id: 'tofu', name: 'Tofu', category: 'Protein', servingUnit: 'g', calories: 76, protein: 8, carbs: 1.9, fat: 4.8 },
  { id: 'whey', name: 'Whey protein powder', category: 'Supplements', servingUnit: 'g', calories: 400, protein: 80, carbs: 8, fat: 6 },
]
