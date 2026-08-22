<script setup lang="ts">
import { ref } from 'vue'
import SectionHeading from '@/components/ui/SectionHeading.vue'
import Button from '@/components/ui/Button.vue'
import { MapPin, Phone, Mail, Building2 } from 'lucide-vue-next'
import { supabase } from '@/lib/supabase'

const form = ref({ name: '', email: '', message: '' })
const sending = ref(false)
const sent = ref(false)
const error = ref('')

const mapSrc =
  'https://www.openstreetmap.org/export/embed.html?bbox=100.4004%2C-0.9160%2C100.4204%2C-0.8960&layer=mapnik&marker=-0.9060499%2C100.4104408'

async function submit() {
  error.value = ''
  if (!form.value.name.trim() || !form.value.email.trim() || !form.value.message.trim()) {
    error.value = 'Semua kolom wajib diisi.'
    return
  }
  sending.value = true
  try {
    const { error: e } = await supabase.from('contact_messages').insert({
      name: form.value.name.trim(),
      email: form.value.email.trim(),
      message: form.value.message.trim(),
    })
    if (e) throw e
    sent.value = true
  } catch (e) {
    error.value = 'Gagal mengirim pesan. Silakan coba lagi.'
  } finally {
    sending.value = false
  }
}
</script>

<template>
  <div class="brand-gradient-bg">
    <section class="mx-auto max-w-3xl px-4 py-16 md:px-6">
      <h1 class="font-display text-3xl font-bold text-ink md:text-4xl">Kontak</h1>
      <p class="mt-3 text-sm text-ink-soft md:text-base">
        Sampaikan pertanyaan atau informasi melalui kanal berikut.
      </p>
    </section>

    <section class="mx-auto max-w-3xl px-4 pb-16 md:px-6">
      <div class="grid gap-4 md:grid-cols-2">
        <div class="glass-gradient rounded-2xl p-5">
          <div class="flex items-center gap-2">
            <MapPin :size="18" class="text-brand-blue" />
            <p class="font-display font-semibold text-ink">Alamat</p>
          </div>
          <p class="mt-2 text-sm text-ink-soft">Universitas Adzkia<br />Jl. Taratak Paneh No. 7, Kel. Korong Gadang, Kec. Kuranji, Padang</p>
          <p class="mt-3 flex items-center gap-2 text-sm text-ink-soft"><Phone :size="15" class="text-brand-blue" /> (0751) 497105</p>
          <p class="mt-1 flex items-center gap-2 text-sm text-ink-soft"><Mail :size="15" class="text-brand-blue" /> informasiadzkia@gmail.com</p>
        </div>
        <div class="glass-gradient rounded-2xl p-5">
          <div class="flex items-center gap-2">
            <Building2 :size="18" class="text-brand-blue" />
            <p class="font-display font-semibold text-ink">Sekretariat Satgas</p>
          </div>
          <p class="mt-2 text-sm text-ink-soft">Lantai 2 Gedung Lama, Universitas Adzkia. Untuk kondisi mendesak yang membutuhkan penanganan segera, gunakan kanal resmi kampus yang berlaku.</p>
        </div>
      </div>

      <div class="glass-gradient mt-8 overflow-hidden rounded-2xl">
        <iframe
          :src="mapSrc"
          title="Peta lokasi Universitas Adzkia, Padang"
          class="h-72 w-full border-0"
          loading="lazy"
          referrerpolicy="no-referrer-when-downgrade"
        ></iframe>
      </div>

      <div class="mt-8">
        <SectionHeading heading="Kirim Pesan" lead="Pesan ini adalah kanal informasi umum dan bukan pengganti pelaporan resmi." />
        <form @submit.prevent="submit" class="glass-gradient grid gap-4 rounded-2xl p-6">
          <div v-if="sent" class="rounded-md bg-brand-blue-soft p-4 text-sm text-link">
            Pesan terkirim. Tim kami akan menindaklanjuti melalui email yang Anda berikan.
          </div>

          <template v-else>
            <label class="grid gap-1">
              <span class="text-sm font-medium text-ink">Nama *</span>
              <input
                v-model.trim="form.name"
                name="name"
                required
                class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink focus:outline-2 focus:outline-link"
              />
            </label>
            <label class="grid gap-1">
              <span class="text-sm font-medium text-ink">Email *</span>
              <input
                v-model.trim="form.email"
                name="email"
                type="email"
                required
                class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink focus:outline-2 focus:outline-link"
              />
            </label>
            <label class="grid gap-1">
              <span class="text-sm font-medium text-ink">Pesan *</span>
              <textarea
                v-model.trim="form.message"
                name="message"
                rows="5"
                required
                class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink focus:outline-2 focus:outline-link"
              ></textarea>
            </label>

            <p v-if="error" class="text-sm text-danger" role="alert">{{ error }}</p>

            <Button type="submit" :disabled="sending">{{ sending ? 'Mengirim…' : 'Kirim Pesan' }}</Button>
          </template>
        </form>
      </div>
    </section>
  </div>
</template>