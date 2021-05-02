Config = {}

Config.Locale = 'de'

Config.PriceLimit = true
Config.MaxPrice = 500000


-----------------------------------------------------
--                    Locales                     --
----------------------------------------------------

Locales = {}

Locales['de'] = {
  ['noPlayerNearYou']   = 'Es befindet sich kein Spieler in deiner Nähe',
  ['notEnoughMoney']    = 'Du hast ~r~zu wenig ~s~Geld bei dir',
  ['overTheLimits']    = 'Die Rechnung ist größer, als der Maximal wert!',

  ['denyBill']          = 'Die Rechnung wurde ~r~zerrissen',
  ['paidBill']          = 'Rechnung von ~g~$%s ~s~bezahlt',
  ['TargetPaid']        = 'Rechnung von ~g~$%s ~s~erhalten',
  ['TargetPaidSociety'] = '~g~$%s ~s~wurden an deine Firma überwiesen'
}

Locales['en'] = {
  ['noPlayerNearYou']   = 'There is no Player near you',
  ['notEnoughMoney']    = 'You dont have ~r~enough ~s~money',
  ['overTheLimits']    = 'Your Bill is higher than the Limit!',

  ['paidBill']          = 'You paid ~g~$%s',
  ['TargetPaid']        = 'You got ~g~$%s ~s~from an Bill',
  ['TargetPaidSociety'] = 'Your Society got ~g~$%s ~s~from an Bill'
}