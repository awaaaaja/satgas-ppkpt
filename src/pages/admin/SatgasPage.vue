<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase, storageUrl } from '@/lib/supabase'

type DosenRow = { id: string; nama: string; jabatan: string; foto_url: string | null; urutan: number }
type MhsRow = { id: string; nama: string; prodi: string; foto_url: string | null; urutan: number }

const dosen = ref<DosenRow[]>([])
const mhs = ref<MhsRow[]>([])
const loading = ref(true)
const err = ref('')

// form untuk dosen
const dForm = ref({ id: '' as string | '', nama: '', jabatan: 'Anggota · Dosen', foto: null as File | null })
const mForm = ref({ id: '' as string | '', nama: '', prodi: 'Mahasiswa PGSD', foto: null as File | null })
const saving = ref(false)

onMounted(loadAll)

async function loadAll() {
  loading.value = true
  const [r1, r2] = await Promise.all([
    supabase.from('satgas_dosen').select('*').order('urutan'),
    supabase.from('satgas_mahasiswa').select('*').order('urutan'),
  ])
  if (r1.error) err.value = r1.error.message
  else dosen.value = (r1.data ?? []) as DosenRow[]
  if (r2.error) err.value = r2.error.message
  else mhs.value = (r2.data ?? []) as MhsRow[]
  loading.value = false
}

// upload foto ke bucket gambar (open-source islami: admin bisa upload foto hijab/modest)
async function uploadFoto(file: File | null): Promise<string | null> {
  if (!file) return null
  const name = `satgas/${Date.now()}-${file.name.replace(/[^a-z0-9._-]/gi, '_')}`
  const { error } = await supabase.storage.from('gambar').upload(name, file)
  if (error) throw error
  return `/storage/v1/object/public/gambar/${name}`
}

async function saveDosen() {
  if (!dForm.value.nama.trim()) { err.value = 'Nama dosen wajib diisi.'; return }
  saving.value = true
  try {
    const foto_url = await uploadFoto(dForm.value.foto)
    const payload: Partial<DosenRow> = {
      nama: dForm.value.nama.trim(),
      jabatan: dForm.value.jabatan,
      ...(foto_url ? { foto_url } : {}),
    }
    if (dForm.value.id) {
      // update: jika foto baru tidak diupload, jangan timpa foto_url
      const upd: Record<string, unknown> = { nama: payload.nama, jabatan: payload.jabatan }
      if (foto_url) upd.foto_url = foto_url
      const { error } = await supabase.from('satgas_dosen').update(upd).eq('id', dForm.value.id)
      if (error) throw error
    } else {
      const { error } = await supabase.from('satgas_dosen').insert({ ...payload, urutan: dosen.value.length + 1 })
      if (error) throw error
    }
    dForm.value = { id: '', nama: '', jabatan: 'Anggota · Dosen', foto: null }
    await loadAll()
  } catch (e) { err.value = (e as Error).message } finally { saving.value = false }
}

async function saveMhs() {
  if (!mForm.value.nama.trim()) { err.value = 'Nama mahasiswa wajib diisi.'; return }
  saving.value = true
  try {
    const foto_url = await uploadFoto(mForm.value.foto)
    const payload: Partial<MhsRow> = {
      nama: mForm.value.nama.trim(),
      prodi: mForm.value.prodi,
      ...(foto_url ? { foto_url } : {}),
    }
    if (mForm.value.id) {
      const upd: Record<string, unknown> = { nama: payload.nama, prodi: payload.prodi }
      if (foto_url) upd.foto_url = foto_url
      const { error } = await supabase.from('satgas_mahasiswa').update(upd).eq('id', mForm.value.id)
      if (error) throw error
    } else {
      const { error } = await supabase.from('satgas_mahasiswa').insert({ ...payload, urutan: mhs.value.length + 1 })
      if (error) throw error
    }
    mForm.value = { id: '', nama: '', prodi: 'Mahasiswa PGSD', foto: null }
    await loadAll()
  } catch (e) { err.value = (e as Error).message } finally { saving.value = false }
}

function editDosen(row: DosenRow) {
  dForm.value = { id: row.id, nama: row.nama, jabatan: row.jabatan, foto: null }
}
function editMhs(row: MhsRow) {
  mForm.value = { id: row.id, nama: row.nama, prodi: row.prodi, foto: null }
}

async function removeDosen(id: string) {
  if (!confirm('Hapus anggota ini?')) return
  const { error } = await supabase.from('satgas_dosen').delete().eq('id', id)
  if (error) err.value = error.message
  else await loadAll()
}
async function removeMhs(id: string) {
  if (!confirm('Hapus anggota ini?')) return
  const { error } = await supabase.from('satgas_mahasiswa').delete().eq('id', id)
  if (error) err.value = error.message
  else await loadAll()
}
</script>

<template>
  <div class="max-w-5xl">
    <h1 class="font-display text-2xl font-bold text-ink">Kelola Struktur Satgas</h1>
    <p class="mt-1 text-sm text-ink-soft">Kelola anggota Dosen & Mahasiswa — foto islami open-source (upload foto hijab/modest ke bucket <code>gambar</code>).</p>
    <p v-if="err" class="mt-4 rounded-md bg-danger/10 p-3 text-sm text-danger" role="alert">{{ err }}</p>

    <div v-if="loading" class="mt-6 py-10 text-center text-muted">Memuat…</div>

    <template v-else>
      <!-- DOSEN -->
      <section class="mt-8">
        <h2 class="font-display text-lg font-semibold text-ink">Anggota Dosen & Tendik</h2>
        <form @submit.prevent="saveDosen" class="mt-3 flex flex-wrap gap-2 rounded-xl bg-white p-4 ring-1 ring-border">
          <input v-model.trim="dForm.nama" placeholder="Nama" class="flex-1 rounded-md border border-border px-3 py-2 text-sm" />
          <input v-model.trim="dForm.jabatan" placeholder="Jabatan" class="flex-1 rounded-md border border-border px-3 py-2 text-sm" />
          <input type="file" accept="image/*" class="flex-1 rounded-md border border-border px-3 py-2 text-sm" @change="dForm.foto = ($event.target as HTMLInputElement).files?.[0] ?? null" />
          <button type="submit" :disabled="saving" class="rounded-md bg-brand-blue px-4 py-2 text-sm font-medium text-white disabled:opacity-60">{{ dForm.id ? 'Update' : 'Tambah' }}</button>
          <button v-if="dForm.id" type="button" @click="dForm = { id: '', nama: '', jabatan: 'Anggota · Dosen', foto: null }" class="rounded-md bg-white px-3 py-2 text-sm ring-1 ring-border">Batal</button>
        </form>
        <div class="mt-4 grid gap-3">
          <div v-for="row in dosen" :key="row.id" class="flex items-center gap-3 rounded-xl bg-white p-3 ring-1 ring-border">
            <img :src="storageUrl(row.foto_url) || `https://placehold.co/80x80/e8f1f9/1a6bb5?text=${encodeURIComponent(row.nama.slice(0,2))}`" :alt="row.nama" class="h-10 w-10 rounded-full object-cover border border-border" />
            <div class="flex-1 min-w-0">
              <p class="truncate text-sm font-medium text-ink">{{ row.nama }}</p>
              <p class="text-xs text-ink-soft">{{ row.jabatan }}</p>
            </div>
            <button @click="editDosen(row)" class="text-xs font-medium text-link hover:underline">Ubah</button>
            <button @click="removeDosen(row.id)" class="text-xs font-medium text-danger hover:underline">Hapus</button>
          </div>
        </div>
      </section>

      <!-- MAHASISWA -->
      <section class="mt-10">
        <h2 class="font-display text-lg font-semibold text-ink">Anggota Mahasiswa</h2>
        <form @submit.prevent="saveMhs" class="mt-3 flex flex-wrap gap-2 rounded-xl bg-white p-4 ring-1 ring-border">
          <input v-model.trim="mForm.nama" placeholder="Nama" class="flex-1 rounded-md border border-border px-3 py-2 text-sm" />
          <input v-model.trim="mForm.prodi" placeholder="Prodi" class="flex-1 rounded-md border border-border px-3 py-2 text-sm" />
          <input type="file" accept="image/*" class="flex-1 rounded-md border border-border px-3 py-2 text-sm" @change="mForm.foto = ($event.target as HTMLInputElement).files?.[0] ?? null" />
          <button type="submit" :disabled="saving" class="rounded-md bg-brand-blue px-4 py-2 text-sm font-medium text-white disabled:opacity-60">{{ mForm.id ? 'Update' : 'Tambah' }}</button>
          <button v-if="mForm.id" type="button" @click="mForm = { id: '', nama: '', prodi: 'Mahasiswa PGSD', foto: null }" class="rounded-md bg-white px-3 py-2 text-sm ring-1 ring-border">Batal</button>
        </form>
        <div class="mt-4 grid gap-3">
          <div v-for="row in mhs" :key="row.id" class="flex items-center gap-3 rounded-xl bg-white p-3 ring-1 ring-border">
            <img :src="storageUrl(row.foto_url) || `https://placehold.co/80x80/e8f1f9/1a6bb5?text=${encodeURIComponent(row.nama.slice(0,2))}`" :alt="row.nama" class="h-10 w-10 rounded-full object-cover border border-border" />
            <div class="flex-1 min-w-0">
              <p class="truncate text-sm font-medium text-ink">{{ row.nama }}</p>
              <p class="text-xs text-ink-soft">{{ row.prodi }}</p>
            </div>
            <button @click="editMhs(row)" class="text-xs font-medium text-link hover:underline">Ubah</button>
            <button @click="removeMhs(row.id)" class="text-xs font-medium text-danger hover:underline">Hapus</button>
          </div>
        </div>
      </section>
    </template>
  </div>
</template>
