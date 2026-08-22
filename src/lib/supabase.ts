import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Supabase URL atau publishable key belum diatur di .env.local')
}

export const supabase = createClient(supabaseUrl, supabaseKey)

/** Ubah path storage relatif (/storage/...) menjadi URL absolut. */
export function storageUrl(path: string | null | undefined): string | null {
  if (!path) return null
  if (path.startsWith('/storage/')) return `${supabaseUrl}${path}`
  return path
}