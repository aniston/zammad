// Copyright (C) 2012-2023 Zammad Foundation, https://zammad-foundation.org/

import { EnumTwoFactorMethod } from '#shared/graphql/types.ts'
import type { TwoFactorPlugin } from '../types.ts'

export default {
  name: EnumTwoFactorMethod.AuthenticatorApp,
  label: __('Authenticator App'),
  order: 200,
  helpMessage: __('Enter the code from your two-factor authenticator app.'),
  icon: {
    mobile: 'mobile-authenticator-app',
  },
} satisfies TwoFactorPlugin
