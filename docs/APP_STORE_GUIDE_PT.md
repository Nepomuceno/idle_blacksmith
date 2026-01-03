# Guia Completo: Publicar na Apple App Store

Este guia detalha todos os passos necessários para publicar o Idle Blacksmith na App Store.

---

## Pré-Requisitos

### Você já tem:
- [x] Apple Developer Account ($99/ano)
- [x] Mac com Xcode instalado
- [x] Godot 4.5 com export templates

### Você precisa criar:
- [ ] App ID no Apple Developer Portal
- [ ] Provisioning Profiles (Development + Distribution)
- [ ] App Record no App Store Connect
- [ ] Screenshots para todos os dispositivos
- [ ] Privacy Policy hospedada online

---

## Parte 1: Apple Developer Portal

### 1.1 Criar App ID

1. Acesse [developer.apple.com](https://developer.apple.com)
2. Vá para **Certificates, Identifiers & Profiles**
3. Clique em **Identifiers** > **+**
4. Selecione **App IDs** > **Continue**
5. Selecione **App** > **Continue**
6. Preencha:
   - **Description**: `Idle Blacksmith`
   - **Bundle ID**: Selecione **Explicit** e digite `com.nepomuceno.idleblacksmith`
7. Em **Capabilities**, deixe o padrão (não precisa de nada especial)
8. Clique **Continue** > **Register**

### 1.2 Criar Certificado de Distribuição (se não tiver)

1. Em **Certificates** > **+**
2. Selecione **Apple Distribution** > **Continue**
3. Siga as instruções para criar um CSR no Keychain Access:
   - Abra **Keychain Access** no Mac
   - Menu **Keychain Access** > **Certificate Assistant** > **Request a Certificate from a Certificate Authority**
   - Email: seu email
   - Common Name: seu nome
   - Selecione **Saved to disk**
4. Faça upload do CSR e baixe o certificado
5. Dê duplo-clique para instalar no Keychain

### 1.3 Criar Provisioning Profiles

#### Profile de Desenvolvimento (para testes):
1. Em **Profiles** > **+**
2. Selecione **iOS App Development** > **Continue**
3. Selecione o App ID `Idle Blacksmith` > **Continue**
4. Selecione seu certificado de desenvolvimento > **Continue**
5. Selecione seus dispositivos de teste > **Continue**
6. Nome: `Idle Blacksmith Development`
7. **Generate** > **Download**

#### Profile de Distribuição (para App Store):
1. Em **Profiles** > **+**
2. Selecione **App Store Connect** > **Continue**
3. Selecione o App ID `Idle Blacksmith` > **Continue**
4. Selecione seu certificado de distribuição > **Continue**
5. Nome: `Idle Blacksmith Distribution`
6. **Generate** > **Download**

### 1.4 Instalar Profiles

1. Dê duplo-clique nos arquivos `.mobileprovision` baixados
2. Eles serão instalados automaticamente

Para verificar:
```bash
ls ~/Library/MobileDevice/Provisioning\ Profiles/
```

---

## Parte 2: Configurar Export no Godot

### 2.1 Obter UUIDs dos Profiles

```bash
# Ver todos os profiles instalados
security find-certificate -a -c "Apple" -p ~/Library/Keychains/login.keychain-db

# Ou abrir o profile para ver o UUID
cat ~/Library/MobileDevice/Provisioning\ Profiles/*.mobileprovision | grep -a UUID -A 1
```

Ou no Xcode:
1. **Xcode** > **Settings** > **Accounts**
2. Selecione sua conta > **Download Manual Profiles**
3. Clique em **Manage Certificates** para ver os certificados

### 2.2 Atualizar export_presets.cfg

Edite o arquivo `export_presets.cfg` na seção `[preset.4.options]` (iOS):

```ini
application/app_store_team_id="YOUR_TEAM_ID"
application/provisioning_profile_uuid_debug="DEBUG_PROFILE_UUID"
application/provisioning_profile_uuid_release="DISTRIBUTION_PROFILE_UUID"
application/code_sign_identity_debug="Apple Development: Your Name (XXXXXXXXXX)"
application/code_sign_identity_release="Apple Distribution: Your Name (XXXXXXXXXX)"
```

**Como encontrar o Team ID:**
- No Apple Developer Portal, seu Team ID aparece no canto superior direito
- Ou em **Membership** > **Team ID**

---

## Parte 3: App Store Connect

### 3.1 Criar App Record

1. Acesse [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Vá para **Apps** > **+** > **New App**
3. Preencha:
   - **Platforms**: iOS
   - **Name**: `Idle Blacksmith`
   - **Primary Language**: English (ou Portuguese)
   - **Bundle ID**: Selecione `com.nepomuceno.idleblacksmith`
   - **SKU**: `idleblacksmith001` (identificador único interno)
   - **User Access**: Full Access
4. Clique **Create**

### 3.2 Preencher App Information

Na página do app, vá para **App Information**:

| Campo | Valor |
|-------|-------|
| Name | Idle Blacksmith |
| Subtitle | Forge Your Legend |
| Category | Games > Simulation |
| Secondary Category | Games > Casual |
| Content Rights | Does not contain third-party content |
| Age Rating | Preencher questionário (ver abaixo) |

### 3.3 Age Rating Questionnaire

1. Clique em **Age Rating** > **Edit**
2. Responda o questionário:
   - Cartoon/Fantasy Violence: **None** (é só forjar, não tem violência)
   - Gambling: **None**
   - Contests: **None**
   - Mature/Suggestive Themes: **None**
   - Unrestricted Web Access: **None**
   - etc.
3. O resultado provável será: **4+**

### 3.4 Pricing and Availability

1. Vá para **Pricing and Availability**
2. **Price**: Free
3. **Availability**: All countries (ou selecione específicos)
4. **Pre-Order**: No

### 3.5 Privacy Policy

1. Vá para **App Privacy**
2. Em **Privacy Policy URL**, coloque a URL onde você hospedou o `privacy_policy.html`

**Opções para hospedar grátis:**
- GitHub Pages: `https://seuusuario.github.io/idleblacksmith/privacy_policy.html`
- Netlify
- Vercel
- Qualquer hospedagem web

### 3.6 Data Privacy (App Privacy)

1. Clique em **Get Started** na seção App Privacy
2. Responda: **"Do you or your third-party partners collect data from this app?"**
   - Se não tem ads: **No**
   - Se tiver AdMob no futuro: **Yes** (AdMob coleta dados)

Para app sem ads, selecione **No** e pronto.

---

## Parte 4: Preparar Screenshots

### 4.1 Tamanhos Necessários

| Dispositivo | Tamanho | Obrigatório |
|-------------|---------|-------------|
| iPhone 6.9" (Pro Max) | 1320x2868 | Sim |
| iPhone 6.7" (Plus) | 1290x2796 | Sim |
| iPhone 6.5" | 1284x2778 | Alternativa |
| iPhone 5.5" | 1242x2208 | Sim |
| iPad Pro 12.9" (6th) | 2048x2732 | Se suportar iPad |
| iPad Pro 12.9" (2nd) | 2048x2732 | Alternativa |

### 4.2 Capturar Screenshots

**No Simulador (mais fácil):**
1. Abra Xcode
2. **Xcode** > **Open Developer Tool** > **Simulator**
3. Escolha um dispositivo (ex: iPhone 15 Pro Max)
4. Rode seu jogo no simulador
5. **File** > **Save Screen** (ou Cmd+S)

**No Godot:**
```bash
# Exportar para iOS e rodar no simulador
godot --headless --export-debug "iOS" builds/ios/IdleBlacksmith.ipa
```

### 4.3 Screenshots Recomendados

Capture pelo menos 4-10 screenshots mostrando:
1. **Splash/Title Screen** - Primeira impressão
2. **Forge Screen** - Gameplay principal
3. **Weapon Collection** - Variedade de armas
4. **Upgrades** - Sistema de progressão
5. **Achievements** - Conquistas
6. **Soul Shop** - Sistema de ascensão

### 4.4 Adicionar Screenshots no App Store Connect

1. Vá para **App Store** > **iOS App** > sua versão
2. Em **App Previews and Screenshots**
3. Arraste as imagens para cada tamanho de dispositivo
4. Você pode usar as mesmas imagens para tamanhos similares

---

## Parte 5: App Description

### 5.1 Description (máx 4000 caracteres)

```
Forge your legend in Idle Blacksmith, an enchanting idle game set in the mystical realm of Aethermoor!

⚒️ THE ETERNAL FORGE AWAITS
Take your place at the legendary Eternal Anvil, an ancient forge that has stood for a thousand years. As the last apprentice of a master blacksmith, you must prove yourself worthy of the ancient souls that dwell within.

🗡️ CRAFT LEGENDARY WEAPONS
From simple iron daggers to divine artifacts of unimaginable power, forge an arsenal worthy of heroes and gods. Each weapon tells a story—what will yours be?

⚡ FEATURES:
• Tap to forge weapons or let auto-forge do the work
• Collect gold and upgrade your smithing abilities
• Discover rare and legendary weapon tiers
• Unlock powerful upgrades that boost your production
• Ascend to gain permanent Ancient Soul bonuses
• Beautiful fantasy-themed graphics and animations
• Relaxing gameplay perfect for any moment

🌟 ASCEND TO GREATNESS
When you've mastered the mortal forge, undergo the Rite of Ascension. Sacrifice your progress to gain Ancient Souls—permanent power that carries across all future runs.

📖 RICH FANTASY LORE
Immerse yourself in the world of Aethermoor, where spirits of ancient master smiths guide worthy apprentices. Uncover the secrets of the First Smith and forge weapons that will outlast the stars themselves.

Free to play with optional non-intrusive ads (coming soon).

Begin your journey. The forge is waiting.
```

### 5.2 Promotional Text (máx 170 caracteres)

```
The Eternal Forge awaits! Craft legendary weapons, collect gold, and ascend to become the greatest blacksmith in all of Aethermoor.
```

### 5.3 Keywords (máx 100 caracteres)

```
idle,blacksmith,forge,clicker,incremental,fantasy,rpg,weapons,craft,casual
```

### 5.4 What's New in This Version

```
Initial release! Welcome to Idle Blacksmith.

• Forge weapons from Common to Eternal tier
• Unlock upgrades and achievements  
• Ascend to gain permanent bonuses
• Beautiful splash screen with game lore
```

---

## Parte 6: Build e Upload

### 6.1 Exportar IPA

```bash
# Na pasta do projeto
godot --headless --export-release "iOS" builds/ios/IdleBlacksmith.ipa
```

Se der erro de signing, verifique:
- Team ID está correto
- Provisioning Profile UUID está correto
- Certificado está instalado no Keychain

### 6.2 Upload via Transporter

1. Baixe **Transporter** na Mac App Store (grátis)
2. Abra o Transporter
3. Faça login com sua Apple ID de desenvolvedor
4. Arraste o arquivo `.ipa` para o Transporter
5. Clique **Deliver**
6. Aguarde o upload e processamento (pode levar 10-30 min)

### 6.3 Upload via Xcode (alternativa)

1. Abra Xcode
2. **Xcode** > **Open Developer Tool** > **Application Loader** (versões antigas)
   Ou: **Product** > **Archive** > **Distribute App**
3. Selecione o IPA e faça upload

### 6.4 Upload via altool (linha de comando)

```bash
xcrun altool --upload-app \
  --type ios \
  --file builds/ios/IdleBlacksmith.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_API_ISSUER
```

Para criar API Key:
1. App Store Connect > **Users and Access** > **Keys**
2. Gere uma nova key e baixe o arquivo `.p8`

---

## Parte 7: Submit for Review

### 7.1 Selecionar Build

1. No App Store Connect, vá para sua versão do app
2. Na seção **Build**, clique **+** ou **Select a Build**
3. Seu build aparecerá após processamento (pode levar alguns minutos)
4. Selecione o build

### 7.2 Preencher Export Compliance

Quando solicitado:
- **"Does your app use encryption?"**: **No**
  (A menos que você use criptografia além do HTTPS padrão)

### 7.3 Preencher Advertising Identifier (IDFA)

- **"Does this app use the Advertising Identifier (IDFA)?"**: 
  - **No** (se ads estão desabilitados)
  - **Yes** (se usar AdMob) - marque as opções apropriadas

### 7.4 Review Final

Verifique todos os campos:
- [ ] Screenshots para todos os tamanhos
- [ ] Description completa
- [ ] Keywords preenchidas
- [ ] Age Rating configurado
- [ ] Privacy Policy URL funcionando
- [ ] Build selecionado
- [ ] Pricing configurado

### 7.5 Submit

1. Clique **Add for Review**
2. Revise as informações
3. Clique **Submit to App Review**

---

## Parte 8: Pós-Submissão

### 8.1 Tempo de Review

- **Primeira submissão**: 24-48 horas (pode ser mais rápido)
- **Updates**: geralmente 24 horas
- Você receberá email quando aprovado ou se precisar de mudanças

### 8.2 Possíveis Rejeições

**Motivos comuns e soluções:**

| Motivo | Solução |
|--------|---------|
| Crash on launch | Teste no dispositivo real antes de submeter |
| Incomplete metadata | Preencha todos os campos obrigatórios |
| Placeholder content | Remova textos como "Lorem ipsum" ou "TODO" |
| Privacy policy issues | Verifique se a URL está acessível |
| Guideline 4.2 (Minimum Functionality) | Adicione mais conteúdo/features se muito simples |

### 8.3 Após Aprovação

1. O app vai para **Ready for Sale** automaticamente (ou na data que você escolheu)
2. Pode levar algumas horas para aparecer em todas as App Stores
3. Celebre! 🎉

---

## Checklist Final

### Apple Developer Portal
- [ ] App ID criado
- [ ] Certificado de distribuição instalado
- [ ] Provisioning Profile de distribuição baixado e instalado

### Godot Export
- [ ] Team ID configurado
- [ ] Profile UUIDs configurados
- [ ] Certificados de signing configurados
- [ ] Icons configurados (todos os tamanhos)
- [ ] Build exporta sem erros

### App Store Connect
- [ ] App record criado
- [ ] App Information preenchido
- [ ] Age Rating configurado
- [ ] Pricing definido (Free)
- [ ] Privacy Policy URL adicionada
- [ ] App Privacy questionário respondido

### Screenshots & Content
- [ ] Screenshots para iPhone 6.9" ou 6.7"
- [ ] Screenshots para iPhone 5.5"
- [ ] Screenshots para iPad (se suportar)
- [ ] Description escrita
- [ ] Keywords definidas
- [ ] Promotional text escrito

### Build & Submit
- [ ] IPA exportado com sucesso
- [ ] Build uploaded via Transporter
- [ ] Build processado e visível no App Store Connect
- [ ] Build selecionado na versão
- [ ] Export Compliance respondido
- [ ] App submetido para review

---

## Recursos Úteis

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [Godot iOS Export Docs](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html)
