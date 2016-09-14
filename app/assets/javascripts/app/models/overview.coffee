class App.Overview extends App.Model
  @configure 'Overview', 'name', 'prio', 'condition', 'order', 'group_by', 'view', 'user_ids', 'organization_shared', 'role_id', 'order', 'group_by', 'active', 'updated_at'
  @extend Spine.Model.Ajax
  @url: @apiPath + '/overviews'
  @configure_attributes = [
    { name: 'name',       display: 'Name',                tag: 'input',    type: 'text', limit: 100, 'null': false },
    { name: 'link',       display: 'Link',                readonly: 1 },
    { name: 'role_id',    display: 'Available for Role',  tag: 'select',   multiple: false, nulloption: true, null: false, relation: 'Role', translate: true },
    { name: 'user_ids',   display: 'Available for User',  tag: 'column_select', multiple: true, nulloption: false, null: true,  relation: 'User', sortBy: 'firstname' },
    { name: 'organization_shared', display: 'Only available for Users with shared Organization', tag: 'select', options: { true: 'yes', false: 'no' }, default: false, null: true },
    { name: 'condition',  display: 'Conditions for shown Tickets', tag: 'ticket_selector', null: false },
    { name: 'prio',       display: 'Prio',                readonly: 1 },
    {
      name:    'view::s'
      display: 'Attributes'
      tag:     'checkbox'
      default: ['number', 'title', 'state', 'created_at']
      null:    false
      translate: true
      options: [
        {
          value:  'number'
          name:   'Number'
        },
        {
          value:  'title'
          name:   'Title'
        },
        {
          value:  'customer'
          name:   'Customer'
        },
        {
          value:  'state'
          name:   'State'
        },
        {
          value:  'priority'
          name:   'Priority'
        },
        {
          value:  'group'
          name:   'Group'
        },
        {
          value:  'owner'
          name:   'Owner'
        },
        {
          value:  'last_contact_at'
          name:   'Last contact'
        },
        {
          value:  'last_contact_agent_at'
          name:   'Last contact (Agent)'
        },
        {
          value:  'last_contact_customer_at'
          name:   'Last contact (Customer)'
        },
        {
          value:  'first_response_at'
          name:   'First Response'
        },
        {
          value:  'close_at'
          name:   'Close time'
        },
        {
          value:  'article_count'
          name:   'Article Count'
        },
        {
          value:  'updated_at'
          name:   'Updated at'
        },
        {
          value:  'created_at'
          name:   'Created at'
        },
      ]
      class:      'medium'
    },

    {
      name: 'order::by',
      display: 'Order',
      tag:     'select'
      default: 'created_at'
      null:    false
      translate: true
      options:
        number:                   'Number'
        title:                    'Title'
        customer:                 'Customer'
        state:                    'State'
        priority:                 'Priority'
        group:                    'Group'
        owner:                    'Owner'
        last_contact_at:          'Last contact'
        last_contact_agent_at:    'Last contact (Agent)'
        last_contact_customer_at: 'Last contact (Customer)'
        first_response_at:        'First Response'
        close_at:                 'Close time'
        article_count:            'Article Count'
        updated_at:               'Updated at'
        created_at:               'Created at'
      class:   'span4'
    },
    {
      name:    'order::direction'
      display: 'Direction'
      tag:     'select'
      default: 'down'
      null:    false
      translate: true
      options:
        ASC:   'up'
        DESC:  'down'
      class:   'span4'
    },
    {
      name:    'group_by'
      display: 'Group by'
      tag:     'select'
      default: ''
      null:    true
      nulloption: true
      translate:  true
      options:
        customer:               'Customer'
        state:                  'State'
        priority:               'Priority'
        group:                  'Group'
        owner:                  'Owner'
      class:   'span4'
    },
    { name: 'active',         display: 'Active',      tag: 'active', default: true },
    { name: 'created_by_id',  display: 'Created by',  relation: 'User', readonly: 1 },
    { name: 'created_at',     display: 'Created',     tag: 'datetime', readonly: 1 },
    { name: 'updated_by_id',  display: 'Updated by',  relation: 'User', readonly: 1 },
    { name: 'updated_at',     display: 'Updated',     tag: 'datetime', readonly: 1 },
  ]
  @configure_delete = true
  @configure_overview = [
    'name',
    'link',
    'role',
  ]

  @description = '''
Übersichten können Sie Ihren Agenten und Kunden bereitstellen. Sie dienen als eine Art Arbeitslisten von Aufgaben welche der Agent abarbeiten soll.

Sie können auch individuelle Übersichten für einzelne Agenten oder agenten Gruppen erstellen.
'''

  uiUrl: ->
    '#ticket/view/' + @link
