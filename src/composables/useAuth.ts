import { ref } from 'vue'
import { supabase } from '@/lib/supabase'

const session = ref<Awaited<ReturnType<typeof supabase.auth.getSession>>['data']['session']>(null)
const profile = ref<{ id: string; full_name: string | null; role: string } | null>(null)

export async function getSession() {
  const { data } = await supabase.auth.getSession()
  session.value = data.session
  return data.session
}

export async function getProfile() {
  const s = session.value ?? (await getSession())
  if (!s) {
    profile.value = null
    return null
  }
  const { data } = await supabase
    .from('profiles')
    .select('id,full_name,role')
    .eq('id', s.user.id)
    .maybeSingle()
  profile.value = (data as typeof profile.value) ?? null
  return profile.value
}

export async function signIn(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password })
  if (error) throw error
  session.value = data.session
  await getProfile()
  return data.session
}

export async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) throw error
  session.value = null
  profile.value = null
}

export function useAuth() {
  return { session, profile, signIn, signOut, getSession, getProfile }
}