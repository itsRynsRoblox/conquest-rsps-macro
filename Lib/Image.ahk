#Requires AutoHotkey v2.0

;GUI
global Minimize := "Images\minimizeButton.png" 
global Exitbutton := "Images\exitButton.png" 

global EastCorp := "Images\east_corp.png" 

;FindText Text and Buttons
;InformationBooth:="|<>*138$36.1zz0001zzU001zyU0000TU00001k00401k00471s00491s00411s00411s00401k00401k00401s00001s00401w007zzw0007zy001zzy0003zz0001zzU000zzz000zzz000Tzz000Dzz0007zz0000Nz000Dzy0007zy000Dzy000Dzy000Dzy000Dzy000Dzw0000000000000000000U"
AreaText:="|<>*109$36.szzzzzszyzzzkM8A27mM842LU8k0W7U8k8X770sA07DZwC27zzzzzzzzzzzzU"
Spawn:="|<>*183$71.00Tzzzzzzy0001zzzzzzzy0007zzzzzzzy040Tzzzzzzzy0Q1zzzzzzzzz1w7zzyzzrzzz7wTzzkzz1zzzTzzzw1zy0zzzzzzzU3zw0Dzzzzzs03zk03zzzzy007zU00zzzzk00Dz000zzzzk00Ty007zzzzw00Tw00zzzzzy00zk07zzzzzz01zU0zzzzzzzz1z7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxzzzzzzzzzzzszzzzzzzzzzz0DzzzzzzzzzzU7zzzzzzzzzz03zzzzzzzzzz"
HealthBar:="|<>*74$123.y0000000000000000000Tk0000000000000000003y0000000000000000000Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
UnderAttack:="|<>*93$169.F00000000U0008000040000000448U0000000E0004000020001200224E000000080002000010000V00111E00000004000100000U000EU00UUEQF0scs3WIQC3YEF/1llECCQQCGE8F8UWMW29AF8WG88aF94k8Y8F8+848YED8F0wY8Xm944G94WE3m47Y6424G88YD0WG7W94W294WS82924G2U12944G40F9214WD14WF8414V29190UsQ1t1s7YUwSD0UQF7Xm0SAMwQWU00000000000000E000000000000000000000000000800000000000000000000000000180000000000000E"


;Interfaces
Bank:="|<>*112$149.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz0bzzsDzztzzzzyDzzzzzzzzzzbDzznDzznzzzztDzzzzzzzwzzCTzzaTzzbzzwTbzzzzzzzztzyQzzzAzzzDzzmTDzzzzzzzznzwsD3y3ksCHy7byTksDXaQD1VztlAnwnAlADtbDwzAlCHAnAzDznaNbtb1aMznADtyNaNaNaQCTzbAkTnAnAkzaQznwnAnAn1zAzzCNbzaNaNYzAtzmNaNmNaTyNzyQnUz1sAnAz3nzlsQnksS31szzzzzzzzzzzzzbzzzzztzzzzzzzzzzzzzzzzzzDzzzzznzzzzzzzzzzzzzzzzzwzzzzzzbzzzzzzzzzzzzzzzzzzzzzzzzDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"
TeleportInterface:="|<>*111$129.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw3zbzzzzzzsTzzzzzzzzzztzwzzzzznz3znzzzzzzzzzDzbzzzzyTwzyTzzszzzzztzwzzzzznzbznzzyHzzzzzD3b3kwC67wsC73VnsS73ztnAnAnAlnzb4nnASSNbnDzCNaNaNaSTwtaSNbVsAyNztkQkQnAnnzbAnkQySNbkTzCTaTaNaSTsNaSTbnnAyTztsAsA7Vnsz3AssAyT1ksDzzzzzbzzzzzzzzzznzzzzzzzzzwzzzzzzzzzzyTzzzzzzzzzbzzzzzzzzzzbzzzzzzzzzwzzzzzzzzzzzzzzzzU"
DonatorRank:="|<>*118$47.zzzzzzzzzzzzzzzzzzzzzzzzlzzzzzzzhzzzrzzzRzzzjzzyvb7bCRTxqqqqvNzvhhiBqrzrPPPPhjzVtqsvbTzzzzzzzzzzzzzzzzzwDzyzzzzvjzxzzzzrTzvzzzzVtlpzzzzLhhbTzzyrXPDzzzxqqqjzzzviBhfzzzzzzzzzzzzzzzzzk"
AttackPrompt:="|<>*107$46.zzzzzzzzlzzzzzDyHbbzzwznaSTzznzCNtzzzDw1VVkwAbnaSSNbkzCNtw6T7wtbbaNwDnaSSNbmTCQQQ73Azzzzzzzzzzzzzzzy"

;Objects
BrimstoneChest:="|<>*96$31.0000007zzU07zzz07zzzs7zzzy7zzzz7zzzzXzzzzlzzzzszzzzwTzzzyDzzzy7zzzz3zzzzUzzzzkzzzzsTzzzwDzzzy7zzzz3zzzzXzzzzlzzzzwzzzzwTzzzyDzzzy7zzzz3zzzzUTs1z00000000000U"
InformationBooth:="|<>*138$37.00000000000003zy0001zz0000zzU00000M000zzw0000070000Q3U00811k0040Us00200w00100S000U0D000E07k00803s00401y001zzz000Tzzk007zzs0007zy0001zzy000zzzU00Dzzk003zzs000zzs000Dzw000Avy0007zz0003zzU001zzk000zzk000zzs000Tzw0007zy0000000000000E"

BlueMoonMinimap:="|<>*158$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzwzzzzzzzzzzzkzzzzzwzzzzzVzzzznkzzzzzbzzzz3Vzzzzzzzzzy7bzzzzzzzzzyTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
BloodMoonMinimap:="|<>*123$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzznzzzzzzzzzzD3zzzzzzzzzwC7zzzzwzzzzsSTzzzzkzzzztzzzzzzVzzzzzzzzzzzbzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
EclipseMoonMinimap:="|<>*92$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzkDzzzzzzzzzzUTzzzzzzzzzy0Tzzzzzzzzzk0Dzzzzzzzzs001zzzzzzzzk003zzzzzzzzU007zzzzzzzz000Dzzzw3zzw000DzzkM7zzs000TzzUU7zzU180Tzy003zw01U0Dzk187zs0000TzYVUDzk0000zz600TzU0001zy000zz00003zw001zy00007zs10Dzz0000zzw30zzz0003zzw61zzy0007zzsDzzzy000Tzzzzzzzw000zzzzzzzzs001zzzz"

AFKCooking:="|<>*107$175.00000000000000000000000000000000000000000000000000000000000wE000000E000800M00U00100000E0F80000008021400G00E000U0W00808Y0000004010W00E008E00E0F00404WAACA1lWAAkNkk83351kkC9AlXW03V998911998E8YY42GH4YY4YYF99010b3X70Msb484GQ2199WGG2GG8YYU0UG2EG02EG242980YYYd991994GG00E8stksC78sl0YXUAAAGYXUsMF6980000000000000000000000E000000000000000000000000000180000000000000000000000000000M0000000E"
CookingIcon:="|<>*100$115.000000000000000000000000000000000000000000000000000000000000000000000000000000zzzjzzzzzzzzzzy0000UE0000000000010U000U8000000000000U8000E8000000000000840009c0000000000002m000480000000000000V0002800000000000008U001800000000000002E000s00000000000000s000E00ns00000000004000800kzU000000000200040QQTy000000000100020y6Dzk000000000U0011z3Xzy000000000E000VzlkzzU000000008000EjsATzs0000000040008jy67zw0000000020004rzVVzz0000000010002PzsszzU00000000U001AzySzzk00000000E000WDzjzzk000000008000FXzzzzs0000000040008ETzzzs0000000020004+0Tzzw00000000100022U07zw000000000U0011303zy000000000E000UUTzzz0000000008000Ek0zzzU0000000040008k003zs0000000020004k000Dy0000000010002k0007zU00000000U001M0003zs00000000E000s0001zy000000008000M0000zz000000004000A0000Tzk0000000200060000Dzs00000001000200007zw00000000U00100003zy00000000E000U0001zz000000008000M0001zzU00000004000A0000zzk0000000200060000zzk000000010003U000Tzs00000000U001k000Tzw00000000E000g000Dzw000000008000HU00Dzw0000000040008M00Dzs00000000200047k0Dzk00000000100020TkzzU000000000U00100zzy0000000000E000U000000000000008000E000000000000004000800000000000000200040000000000000010002000000000000000U0010000A0040000000E000U000900500000008000E000/E02U00000040008000/M01EU000002000400050sQeeks000100020002UWFKiYW0000U0010001EirOvBiU000E000U000cJOgpipE0008000I000IehKepOc000Q00090005hqvPOho000G0004E001B6XehJ2000F00024000QSDAxaR000EU001B000000000GU00KE000UE00000000LE00E8000E4000000004M00E400042000000001s00840001zzzzzzzzzzzzzzw000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"
AFKSmithing:="|<>*116$175.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000D40000004000200C002000200000U4G000000200UF008U0F000101400E29000000100E8U04018UU00U0W00818X33X0QMX3A6QA1kc6Q3VUQGNX740sGGG2EEGGG429904eG9998998WGG0E9kslk6C9l214b02J94YYY4YYF99084UY4U0Y4UV0WG0G+YWGGG2GG8YY042CCQC3VmCAE98s65G99971kkWAGE0000000000000000000000U0000000000000000000000000002E0000000000000000000000000000k0000004"
SmithingIcon:="|<>*99$92.jzzzy0000000010bzzzzzzy000000E7k000zzzk0000021s0007zzw000000KQ0000y1z000000270000C0DU000000Fk0003U7k0000002Q0000s3s0000000TU000C1w00000001s0003Uy00000000T3zzssT000000007sTzzTzU00000001T7zzzzk00000000Hxzzzzs000000004Tjzzzw0000000013zzzzy000000000ETzzzy00000000041zzzz00000000010DzzzU000000000E0Tzzk000000000403zzs000000000100Tzw0000000000E03zy0000000000400Tz00000000001007zs0000000000E03zy0000000000401tDk000000000101w0z0000000000E1y03w00000000040y00TU0000000010S001w000000000ED000DU0000000043k003s0000000010w000y000000000ED000zU0000000041w07zs0000000010Tzzzw000000000E3zzzy0000000004000000000000001000000000000000E000000000000004000000000000001000000000000000E000000000000004000000000000001000000000000000E000000000000004000000000000001000000000000000E000000000000004000000000000001000000000000000E0000000000000040000000000000010000k0020000000E000G00FE0000004000/E0+I00000010005g0+Z1000000E000cBZhQeks000400054YsobGF00010000eqqwqnPc000E0005hhdRhqe00050009PPOJPJeU0078005iqqpKpPc002F000ahhHJhJ2001480076qngqnCU00VB0000000004c00IE8000000002u00841000000000FU041UE000000003k010bzzzzzzzzzzzzzzm"
AFKFarming:="|<>*112$169.00000000000000000000000000003l00000010000U07U0000080000214U000000U084E02000000404E010WE000000E042801000200202800UG8kksk768kn1b30slFEC61l9aAQEC4YYUY44YYV0WGEEYlIYYUYYW99842QCAQ1XWQEUF9k8CEeGGEGGF4YY21891809188E8YU498J998998WGE10XXb3UsQXX42GC23Y+YYQ7328l90000000000000000000002000000000000000000000000000900000000000000000000000000030000000U"
FarmingIcon:="|<>*99$92.E800w700000000UM200wMw000000082100QDXU00000010aU0AQSA0000000/8E03A1lU00000012801y06M00000008Y00T00n00000001C00Dzz7k0000000C003zzzw00000000UDUzzzzU00000008CwDrzzs00000002CTbnUDy00000000iTNzU0TU0000000DTqTk0Ls00000003zlbw0zz00000000zklzzzss0000000DwATbza300000003zX7s00kM0000000jsNy00Dn0000000863TU03yM00000021kzs00zv0000000UC7y00DzE00000083kzU03zq00000020SDs00yzU000000U3ny00Dbs00000080zzU03ty000000207zs00yDU000000U1zy00DXs00000080DzU03sy000000203zs00yDU000000U0Ty00Tzs000000807zk07zy000000200zw01zzU000000U0DzU0zzk000000801zs0Dzs000000200Dz07zw0000000U03zs1zy0000000800Tztzy00000002007zzzy00000000U00zzzz000000008003zzzU00000002000DzzU00000000U000zzU000000008000000000000002000000000000000U000000000000008000000000000002000000000000000U000000000000008000000000000002000000000000000U000000000000008000000000000002000000000000000U000T000000000080008800000000020002y0000000000U000c00020000008000/3WXNJVk0002000295J9CYW0000U000iinhharE0008000+4BfPPhI0002U002WvGqqfJ0003Y000ciohherE0018U00+4B/POe4000W4001UylhhaR000EaU000000009E00/84000000005o00420U00000000X0020E8000000007U00UHzzzzzzzzzzzzzzu"

HealthBarNew:="|<>*70$15.zzs0000000000000000000000000000000000000007zzU"
Login:="|<>*115$114.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs0zzs3zy03k10Dk3zzzw0zzU0zs03k3U7k7zzzy3zz3kTkzXwDs7wTzzzy3zy7sDVznwDs3wTzzzy3zwDwDVznwDs1wTzzzy3zwDw73zzwDt0wTzzzy3zsDw63zzwDtUQTzzzy3zsDy23zzwDtkQTzzzy3zsDy23zzwDtkATzzzy3zsDy23w0wDts4Tzzzy3zsDy23w0QDtw0Tzzzy3zsDy23z1wDty0Tzzzy3zsDy33z3wDtz0Tzzzy3zsDy71z3wDtzUTzzzy3zQ7w7Vz3wDtzkTzzzy3yS7wDUz3wDtzsTzzzy3wy3sTkT3w7szwTzzzy00z1kzw07k30DwTzzzs00zk3zzUzk30DzzzzzzzzzyDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"
InactiveWave:="|<>*32$51.0000000000000000000000000000000000300000000E000U000200040000E00010002463b14M0H84UV0YE2F6Y48c20G94UV17U0F0U08E00u8wQN23k00000000000000000U"
FrozenFragment:="|<>*154$17.zzzzzzyzzyzzzzzzzzzzrwzhhvzUrjVjzzTzyzzxzztzzrzzzzzU"
SlayerTask:="|<>*117$62.zzzzzzzzzzyCzzzzsDzvzRjzzzzjzyzrvzzzzvzzjyCtqtpywwOzxhhhgziqyRzPXP7TvlnbxiqsrryvTOzbiDiBzj6CpzzzvzzzzzzzzzqzzzzzzzzzyTzzzzzzU"
NoSlayerTask:="|<>*116$71.zzzzzzzzzzzzzzzzzzzzzzzzzXjzzzy3zyzzyvTzzzzTzxzzxyzzzzyzzvzzwRnhnfxtspzzzPPPPDvhjbTzyr6qCzrXbDzzPhiBxzirqjzzDQTQPzSARfzzzzyzzzzzzzzzzzhzzzzzzzzzzzbzzzzzzzzzzzzzzzzzzzzzzzRzzzzzzzzzzyPzzzzzzzzzzxLzzzzzzzzzzuiQSTzzzzzzzpPPPTzzzzzzzgqqlzzzzzzzzNhhjzzzzzzzyvbPXzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

;Slayer Tasks
ArcaneNagua:="|<>*49$71.0000000000000000000E0000E000008U0001400000J000008FW620e88G87H4191144YY48Y8+GQ28d98cF804Y04EEEEEWEMt8s8XWX3U00000000100000000000200000000000M00U"
ElysianNagua:="|<>*110$71.zzzzzzzzzzzzVTzzzzvjzzzzSzzzzznTzzzyxzzjzzezzzzwPPXwszJnnhnvqqyqqyfPPPPrhiRlhxb6qr7jQTPPPvBhhhj2ylr6rrQQQwTzxzzzzzzyzzzzPzzzzzzhzzzzDzzzzzzbzzzzzzzzzzzzzz"
SpectralNagua:="|<>*107$78.zzzzzzzzzzzzzlzzzzzxxrzzzzizzzjzxwrzzzzjzzzjzxxLzzzzltttaiRxLDCrDyqqriRhxKqqqryqlriyBxb6qr7hqrrixhxaqqqrnlstqyBxr77D7zrzzzzzzzzrzzzrzzzzzzzyrzzzrzzzzzzzzDzzU"
ElectricWyrm:="|<>*49$66.00000000000DE0000000008E0400000000E000U00000CF1a4314Y808EG4MY14YlI8HW4EY1I4VI0E00EU04IVIDFlWEX0s4VI000000004000000000040000000000M0000000000000U"
Vanguards:="|<>*52$48.00000002F0000002F000000210000002+4A4942++19991AG2599958G419111824795678C000100000001000000060000U"
Sarachnis:="|<>*107$54.szzzzjzzzrTzzzjzzzrzzzzjzjzswuttXXyDzPNqrhhhzzQPsrhhiTqvPqrhhjjtwPsthhgTzzzzzzzzzzzzzzzzzzzzzzzzzzzU"
Galvek:="|<>*96$39.zzzzzzznzjzyzxjxzzrzTzjzyzvyRitpzPhhqqTviBplnzhhiiyjySBvsqzzzzzzzU"
MagmaBeast:="|<>*108$69.zzzzzzzzzzzzSzzzzzTzzzztbzzzzvzzzvzGzzzzzTzzzTvrDDLbswwwNzSqqpPTPPPTTvr6qfXvMwQvzSqqpPTPTPvTvr76fXswQMxzzzyzzzzzzzzzzyrzzzzzzzzzztzzzzzzzzU"
TormentedDemon:="|<>*108$95.zzztzzzzzzzzzzzzzzzzzzzzjzzzzzzy3zzzzzzzT7zzzzzzTzzzzxzyyrzzzzzyzzzzzvzxxrzzzzzxtpptlnbXviSjCDzvhbJhhiqrrPOhhjzrPSf7PQRjilpPPTziqxKyqvvTRjeqqzzSRuiBissy7XJnhzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy"
ShadowCorp:="|<>*100$65.zzzzTzzzzzzlrzyzzzzzzzRjzxzzzzzzyzTzvzzzzzzyCDD7CvwtpnzhhhhhrrhbPzPQPPOjjPSrhqqqqpTSqxjbhllnlzCRszzzzzzzzzzrzzzzzzzzzzjzzzzzzzzzzTzzzzzzzzzzz"
AbyssalKurask:="|<>*107$88.zSzzzzyyzzzzxzzuvzzzzvvTzzzrzzRjzzzzjfzzzzTzxqCr77CySqiSBQTkPPPvvPtvNqrnjzRhhnnljfhjXbDDxqr7rqqyqqxjhTTrMzMswPvgvslqXzzzxzzzzzzzzzzzzzyrzzzzzzzzzzzzzwzzzzzzzzzzzzzzzzzzzzzzzzzzU"
FuryDrake:="|<>*112$55.zzzzzTzzzsTzzzjzvzxzzzzrzxzyzzzzvzyzz6qhjlfbLDjPCrqnhbPrhjPvPsnXvqrlxhvOrxwvyz6yBgTzzzTzzzzzzzxjzzzzzzzzDzzzzzzzzzzzzzzk"
NightBeast:="|<>*112$59.zzzzzzzzzzizyzzTzzzzBzxxyzzzyyfTvvxzzzxxLtlnswwwNuhhhjqqqrrqPPPThXlnjgqqqzPTPvTRiBiyD76DTzzTzzzzzzzzqzzzzzzzzznzzzzzzzzzzzzzzzzz"
ShadowNihil:="|<>*111$65.zzzzTzzzzzzlrzyzzzzvzTRjzxzzzzryyzTzvzzzxjhyCDD7Cvsz7vzhhhhhrqqqrzPQPPOjhhhjhqqqqpTPPPTbhllnlyqqqzzzzzzzzzzzs"
Pyrelord:="|<>*107$86.zzzzzzzzzzzzzxw/zzzzzVzzzjzzTSzzzzzvjzzvzzrrjzyzzyvzzyzzxwPbfwSThqpniRQTSqpPPPsxgvPPCrriBKqqyzPSCqrhxvPJhhjjsrjhhvTSspPPXvzhwPbT7zzzzzyzzvzzzzzzzzzzxjzqzzzzzzzzzzzbzyTzzzzzzzzzzzzzzzzzzzs"


