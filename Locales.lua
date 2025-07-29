local _, S = ...
local pairs, ipairs, string, type, time = pairs, ipairs, string, type, time

local locales = {
    [1] = "enUS",
    [2] = "enGB",
    [3] = "frFR",
    [4] = "deDE",
    [5] = "itIT",
    [6] = "koKR",
    [7] = "zhCN",
    [8] = "zhTW",
    [9] = "ruRU",
    [10] = "esES",
    [11] = "esMX",
    [12] = "ptBR",
}
local localesFallback = {
    ["zhCN"] = "zhTW",
    ["zhTW"] = "zhCN",
    ["esES"] = "esMX",
    ["esMX"] = "esES"
}
local localizations = {}
for _, locale in pairs(locales) do
    localizations[locale] = {}
end

-- Loads the TSV as a string locally to be cleared by the garbage collector after
-- Parses it to fill the localizations table
local function ParseTSV()
-- Tab Separated Values spreadsheet imported directly from https://docs.google.com/spreadsheets/d/17eIDO0UU86-DUYjvu_ZyJ_9b8kMA9kTbAMDiQ0elXQA/edit?usp=sharing
local tsv = 
[[TITLE	Sorted.	Sorted.	Sorted.	Sorted.	Sorted.	Sorted.	Sorted.	Sorted.	Sorted.	Sorted.	Sorted.	Sorted.
NOTES	Modern bag interface with efficient searching and filters.	Modern bag interface with efficient searching and filters.	Interface de Sac moderne avec un système de recherche et de filtre efficace.	Moderne Taschendarstellung mit effzienter Suche und Filtermöglichkeiten	Moderna interfaccia di zaino con filtri e ricerca efficienti. 	효율적인 검색 및 필터 기능을 갖춘 현대적인 가방 인터페이스.	现代的背包界面，并带有高效搜寻以及过滤分类功能。	摩登酷炫的背包介面，並帶有高效搜尋以及過濾分類功能。	Современный интерфейс сумки с эффективным поиском и фильтрами.	Interfaz de bolsa moderna con búsqueda eficiente y filtros	Interfaz de bolsa moderna con búsqueda eficiente y filtros	Uma bolsa com interface moderana, com funções eficientes de filtros e procura
BAGS	Bags	Bags	Sacs	Taschen		가방	包	包		Bolsas		Bolsas
REAGENT_BAG	Reagent Bag	Reagent Bag		Reagenzientasche		재료 가방	材料包	材料包		Bolsa de componentes		Bolsa de reagente
BANK	Bank	Bank	Banque	Bank		은행	银行	銀行		Banco		Banco
REAGENTS	Reagent Bank	Reagent Bank	Sac de composent	Materiallager		재료 은행	材料银行	材料銀行		Banco de componentes		Banco de reagente
FILTERED_ITEMS	Filtered	Filtered		Gefiltert		걸러짐	已过滤	已過濾		Filtrado		
CATEGORY_WEAPONS	Weapons	Weapons	Armes	Waffen	Armi	무기	武器	武器	Оружие	Armas	Armas	Armas
CATEGORY_ARMOR	Armor	Armour	Armure	Rüstung	Armature	방어구	护甲	護甲	Доспехи	Armadura	Armadura	Armadura
CATEGORY_ACCESSORIES	Accessories	Accessories	Accessoires	Accessoires	Accessori	장식	配件	配件	Аксессуары	Accesorios	Accesorios	Acessórios
CATEGORY_CONTAINERS	Containers	Containers	Conteneurs	Behälter	Borse	가방류	容器	容器	Сумки	Recipientes	Contenedores	Recipientes
CATEGORY_GEMS	Gems	Gems	Gemmes	Edelsteine	Gemme	보석	宝石	寶石	Камни	Gemas	Gemas	Gemas
CATEGORY_ITEM_ENHANCEMENTS	Item Enhancements	Item Enhancements	Améliorations d’objet	Gegenstandsverzauberungen	Potenziamenti oggetto	아이템 강화	物品强化	物品附魔	Улуч. предметов	Mejoras de objetos	Mejoras de objetos	Aperfeiçoamentos de Itens
CATEGORY_CONSUMABLES	Consumables	Consumables	Consommables	Verbrauchbare Gegenstände	Consumabili	소비용품	消耗品	消耗品	Расход. предметы	Consumibles	Consumibles	Consumíveis
CATEGORY_GLYPHS	Glyphs	Glyphs	Glyphes	Glyphen	Glifi	문양	雕文	雕紋	Символы	Glifos	Glifos	Glifos
CATEGORY_TRADE_GOODS	Trade Goods	Trade Goods	Fournitures d’artisanat	Handwerkswaren	Beni commerciali	직업용품	商品	商品	Хоз. товары	Objetos comerciales	Objetos comerciables	Mercadorias
CATEGORY_RECIPES	Recipes	Recipes	Recettes	Rezepte	Ricette	제작법	配方	配方	Рецепты	Recetas	Recetas	Receitas
CATEGORY_BATTLE_PETS	Battle Pets	Battle Pets	Mascottes de combat	Kampfhaustiere	Mascotte da combattimento	전투 애완동물	战斗宠物	戰寵	Питомцы	Mascotas de duelo	Mascotas de duelo	Mascotes de Batalha
CATEGORY_KEYS	Keys	Keys	Clés	Schlüssel		열쇠	钥匙	鑰匙		Llaves		Chaves
CATEGORY_QUEST_ITEMS	Quest Items	Quest Items	Objets de quête	Questgegenstände	Oggetti di missione	퀘스트 아이템	任务物品	任務物品	Для задания	Objetos de misión	Objetos con misión	Itens de missão
CATEGORY_MISCELLANEOUS	Miscellaneous	Miscellaneous	Divers	Verschiedenes	Varie	기타	杂项	雜項	Разное	Miscelánea	Miscelánea	Diversos
ITEM_BACKPACK	Backpack	Backpack	Sac à dos	Rucksack	Zaino	배낭	背包	背包	Рюкзак	Mochila	Mochila	Mochila
ITEM_UNKNOWN_KEYSTONE	Mythic Keystone	Mythic Keystone	Clé mythique	Mythischer Schlüsselstein	Chiave del Potere	신화 쐐기돌	史诗钥石	傳奇鑰石	Ключ	Piedra angular mítica	Piedra angular mítica	Pedra-chave Mítica
ITEM_MYTHIC_KEYSTONE	Keystone: %s	Keystone: %s	Clé : %s	Schlüsselstein: %s	Chiave del Potere: %s	쐐기돌: %s	钥石：%s	鑰石：%s	Ключ: %s	Piedra angular: %s	Piedra angular: %s	Pedra-chave %s
ITEM_PET_CAGED	Pet Cage: %s	Pet Cage: %s	Mascotte en cage	Haustierkäfig: %s	Mascotte in gabbia: %s	애완동물 우리: %s	宠物笼：%s	寵物籠：%s	Клетка для питомца	Jaula de mascota: %s	Jaula de mascota: %s	Jaula de Mascote
COLUMN_FAVORITES	Favorites	Favourites	Favoris	Favoriten	Favorito	즐겨찾기	最爱	最愛	Избранное	Favoritos	Favoritos	Favoritos
COLUMN_QUANTITY	Quantity	Quantity	Quantité	Menge	Quantità	수량	数量	數量	Кол-во	Cantidad	Cantidad	Quantidade
COLUMN_MAX_STACK	Stack Size	Stack Size	Taille de pile	Stapelgröße		겹쳐짐 갯수	堆叠数量	堆疊數量		Tamaño de montones		Tamanho da pilha
COLUMN_MAX_STACK_SHORT	Max	Max	Max	Max		최대	最多	最多		Máximo de montones		Máximo
COLUMN_ICON	Icon	Icon	Icône	Symbol	Icone	아이콘	图标	圖示	Значок	Icono	Icono	Ícone
COLUMN_NAME	Name	Name	Nom	Name	Nome	이름	名称	名稱	Имя	Nombre	Nombre	Nome
COLUMN_NAME_SHORT	Name	Name	Nom	Name	Nome	이름	名称	名稱	Имя	Nombre	Nombre	Nome
COLUMN_RARITY_SHORT	Rarity	Rarity	Rareté	Seltenheit	Rarità	희귀도	质量	質量	Редкость	Rareza	Rareza	Raridade
COLUMN_PROFESSION_QUALITY	Profession Quality	Profession Quality		Herstellqualität		전문 기술 품질	专业物品质量	專業物品質量		Calidad de profesión		Qualidade da profissão
COLUMN_REQUIRED_LEVEL	Required Level	Required Level	Niveau Requis	Benötigtes Level	Livello Richiesto	최소 요구 레벨	需要等级	需求等級	Рек. уровень	Nivel necesario	Nivel necesario	Nível necessário
COLUMN_REQUIRED_LEVEL_SHORT	Req	Req	Req	Ben.	Ric.	최소렙	需求	需求	рек.	Necesita	Necesita	Necessário
COLUMN_ITEM_LEVEL	Item Level	Item Level	Niveau d'Objet	Gegenstandslevel	Livello Oggetto	아이템 레벨	物品等级	物品等級	Ур. предмета	Nivel de objeto	Nivel de objeto	Nível de Item
COLUMN_ITEM_LEVEL_SHORT	Lvl	Lvl	Nv	Lvl	Lvl	템렙	等级	等級	ур.	Nivel	Nivel	Nível
COLUMN_TIME_ADDED	Age	Age	Heure d'Ajout	Hinzugefügt	Tempo Aggiunto	획득 시기	添加时间	加入時間	Время	Tiempo añadido	Tiempo añadido	Adquirido em
COLUMN_TIME_ADDED_SHORT	Age	Age	Age	Alter	Età	획득	时间	時間	Время	Antigüedad	Antigüedad	Idade
COLUMN_TYPE	Type	Type	Type	Typ	Tipo	종류	类型	類型	Тип	Tipo	Tipo	Tipo
COLUMN_TYPE_SHORT	Type	Type	Type	Typ	Tipo	종류	类型	類型	Тип	Tipo	Tipo	Tipo
COLUMN_EQUIP_LOCATION	Equipment Slot	Equipment Slot		Ausrüstungsplatz		장착 칸	装备栏	裝備欄				
COLUMN_EQUIP_LOCATION_SHORT	Slot	Slot		Platz		칸	栏	欄				
COLUMN_BINDING	Binding	Binding	Lié	Bindung	Legatùra	귀속	绑定类型	綁定類型	Привязка	Ligar	Ligar	Vinculação
COLUMN_BINDING_SHORT	Bind	Bind	Lien	Bind	Leg.	귀속	绑定	綁定	Перс.	Ligado	Ligado	Vinculado
COLUMN_EXPANSION	Expansion	Expansion	Extension	Erweiterung	Espansione	확장팩	资料片	資料片	Расширение	Expansión	Expansión	Expansão
COLUMN_EXPANSION_SHORT	Xpac	Xpac	Ext.	Erw.	Esp.	확팩	资料片	資料片	Расш.	Expan	Expan	Expan
COLUMN_SELL_PRICE	Sell Price	Sell Price	Prix de Vente	Verkaufspreis	Prezo di Venda	판매 가격	售出价格	售出價格	Цена продажи	Precio de venta	Precio de venta	Preço de venda
COLUMN_SELL_PRICE_SHORT	Value	Value	Valeur	Wert	Valore	값	售价	售價	Цена	Valor	Valor	Valor
COLUMN_TRASH	Trash	Rubbish	Déchets	Plunder		잡템	垃圾	垃圾		Basura		Lixo
COLUMN_MAX_QUANTITY	Max	Max	Maximum 	Maximum		최대	最多	最多		Maáximo		Máximo
COLUMN_WEEKLY_QUANTITY	Quantity This Week	Quantity This Week	Quantité cette semaine	Menge dieser Woche		이번 주 수량	本周数量	本週數量		Cantidad esta semana		Quantidade essa semana
COLUMN_WEEKLY_QUANTITY_SHORT	#/Wk	#/Wk	#/Sem	#/Wo		#/주	#/周	#/週				#/Sem
COLUMN_MAX_WEEKLY_QUANTITY	Max Per Week	Max Per Week	Maximum par semaine	Max Pro Woche		주당 최대	每周最多	每週最多		Maximo por semana		Máximo por semana
COLUMN_MAX_WEEKLY_QUANTITY_SHORT	Max/Wk	Max/Wk	Maximum/Sem	Max/Wo		최대/주	最多/周	最多/週		Max/Sem		Máximo/Sem
GROUP_HEADING_RECENTLY_UNEQUIPPED	Recently Unequipped	Recently Unequipped				최근 벗어냄	最近未装备	最近未裝備				
GROUPING_CATEGORY	Category	Category	Catégorie	Kategorie	Categorìa	카테고리	类别	類別	Категория	Categoría		Categoria
GROUPING_TRACKED_CHECKED	Showing	Showing		Zeige		보임	显示	顯示				
GROUPING_TRACKED_UNCHECKED	Not Showing	Not Showing		Versteckt		안보임	未显示	未顯示				
TAB_BANK	Bank	Bank	Banque	Bank	Banca	은행	银行	銀行	Банк	Banco	Banco	Banco
TAB_REAGENTS	Reagents	Reagents	Composants	Reagenzien	Reagenti	재료 은행	材料银行	材料銀行	Хранилище	Componentes	Componentes	Mercadorias
TAB_CURRENCY	Currency	Currency	Monnaie	Währung		화폐	货币	貨幣				Moeda
BUTTON_SELL_GRAYS	Sell Grays	Sell Greys	Vendre gris	Verk. Plunder	Vendi grigi	잡동사니 판매	卖出灰色物品	賣出灰色物品	Продажа	Vender grises	Vender grises	Vender cinzas
BUTTON_SELL_TRASH	Sell Trash	Sell Rubbish	Vendre les déchets 	Graue Gegenstände verkaufen		잡템 판매	卖出垃圾	賣出垃圾				Vender lixo
BUTTON_DEPOSIT_REAGENTS	Deposit Reagents	Deposit Reagents	Déposer les composants	Reagenzien lagern	Deposito Reagenti	모든 재료 보관	存入材料	存入材料	Сложить предметы	Depositar Componentes	Depositar Componentes	Depositar Mercadorias
BUTTON_BUY_REAGENTS	Purchase	Purchase	Achats	Kaufen	Acquistare	구입	购买	購買	Покупка	Comprar	Comprar	Comprar
BUTTON_PLACE_ITEM	Place %s into your %s	Place %s into your %s	Placé %s dans votre %s	Lagere %s in Deine %s		%s을(를) %s에 배치	把 %s 放入你的 %s	把 %s 放入你的 %s				Colocar %s na sua %s
WARNING_BUY_REAGENTS	This tab gives you additional storage for raw profession materials.\nDo you wish to purchase this tab?	This tab gives you additional storage for raw profession materials.\nDo you wish to purchase this tab?	Cet onglet vous offre plus d'emplacement de stockage pour les matériaux bruts. Voulez-vous acheter cet onglet?	Dieser Tab gibt Dir zusätzlichen Platz für Rohmaterialien für Berufe. Willst du diesen Tab kaufen?		이 보관함에는 직업용품을 추가로 보관할 수 있습니다.\n이 보관함을 구입하시겠습니까?	此标签页为您提供额外的专业原料存储空间。\n您想要购买此标签页吗？	此標籤為您提供了額外的存儲專業原料的空間。\n您想要購買此標籤頁嗎？	Эта вкладка дает вам дополнительное хранилище для материалов профессии.\nВы хотите приобрести эту вкладку?	Esta pestaña te da almacenaje adicional para materiales de profesiones.\n ¿Te gustaría comprar esta pestaña?	Esta pestaña te da almacenaje adicional para materiales de profesiones.\n ¿Te gustaría comprar esta pestaña?	Esta aba lhe dará espaço adicional para mercadorias.\nVocê deseja comprar esta aba?
WARNING_NO_ITEMS_FOUND	No items found	No items found	Aucun objet trouvé	Keine Gegenstände gefunden	Nessuno item trovato	아이템을 찾을 수 없음	没找到物品	沒找到物品	Пусто	No se encontraron objetos	No se encontraron objetos	Itens não encontrados
WARNING_BANK_NOT_CACHED	Visit a banker once on %s\n to see their bank contents here	Visit a banker once on %s\n to see their bank contents here	Rendre visite à un Banquier au moins une fois sur %s\n pour voir le contenu de leur Banque ici	Besuche den Banker einmalig um den Bankinhalt hier zu sehen		%s의 은행원에게 방문하여\n이곳에서 은행 확인	请在%s\n访问银行柜员一次，以便查阅他的银行物品	請登入%s並訪問銀行職員一次\n來查閱他們的銀行物品	Посетите банкира один раз, чтобы увидеть содержимое банка	Visita un banquero en %s\n para ver el contenido del banco aquí	Visita un banquero en %s\n para ver el contenido del banco aquí	Visite um banqueiro uma vez para poder ver seus itens aqui
WARNING_REAGENTS_NOT_CACHED	Visit a banker once on %s\n to see the contents of their reagent bank here	Visit a banker once on %s\n to see the contents of their reagent bank here	Rendre visite à un Banquier au moins une fois sur %s\n pour voir le contenu de leur Banque de Composants  ici	Besuche den Banker einmalig um den Inhalt der Reagenzienbank hier zu sehen		%s의 은행원에게 방문하여\n이곳에서 재료 은행 확인	请在%s\n访问银行柜员一次，以便查阅他的材料银行物品	請登入%s並訪問銀行職員一次\n來查閱他們的材料銀行物品	Посетите банкира один раз, чтобы увидеть содержимое банка реагентов	Visita un banquero en %s\n para ver los componentes del banco aquí	Visita un banquero en %s\n para ver los componentes del banco aquí	Visite um banqueiro uma vez para poder ver suas mercadorias aqui
WARNING_REAGENTS_NOT_PURCHASED	Visit a banker on %s\n to purchase their reagent bank	Visit a banker on %s\n to purchase their reagent bank	Rendre visite à un Banquier pour acheter leur Banque de Composants	Besuche den Banker einmalig um Reagenzienbankplätze zu kaufen		%s의 은행원에게 방문하여\n 재료 은행 구입	请在%s\n访问银行柜员以便购买他的材料银行	請登入%s並訪問銀行職員\n來購買他們的材料銀行	Посетите банкира, чтобы купить банк реагентов	Visita un banquero en %s\n para comprar el banco de componentes	Visita un banquero en %s\n para comprar el banco de componentes	Visite um banqueiro para comprar seu banco de mercadorias
DROPDOWN_MENU_EQUIPMENT_SET	Equipment Sets	Equipment Sets	Ensembles d'équipement	Ausrüstungssets		장비 구성	套装	套裝設定	Комплект	Sets de Equipo	Sets de Equipo	Conjuntos de equipamento
DROPDOWN_MENU_EQUIPMENT_SET_NONE	No Equipment Set	No Equipment Set	Pas d'ensemble d'équipement	Kein Ausrüstungsset		장비 구성 없음	无套装	無套裝設定	Без комплекта	No hay set de Equipo	No hay set de Equipo	Sem conjuntos de equipamento
DROPDOWN_MENU_CLEAR	Clear	Clear	Vider	Löschen	Spurgàre	초기화	清除	清除	Очистить	Borrar	Borrar	Limpar
DROPDOWN_MENU_INSTRUCTION_SELECT	Select...	Select...	Selectionner...	Wählen...		선택...	选择	選擇				Selecione...
FILTER_TYPE	Type	Type	Type	Typ	Tipo	종류	类型	類型	Тип	Tipo	Tipo	Tipo
FILTER_EQUIP_LOCATION	Equip Location	Equip Location	Emplacement d'équipement	Ausrüstungsplatz	Posizione dello Equipaggiamento	착용 부위	装备位置	裝備位置	Ячейка экипировки	Localización del Equipo	Localización del Equipo	Equipado em
FILTER_SUBTYPE	Subtype	Subtype	Sous type	Untertyp	Sottotipo	소분류	子类别	子類別	Тип	Subtítulo	Subtítulo	Subtipo
FILTER_STATS	Stats	Stats	Stats	Attribute	Attributo	능력치	属性	屬性	Характеристики	Estadísticas	Estadísticas	Status
FILTER_QUALITY	Quality	Quality	Qualité	Qualität	Qualità	품질	品质	品質	Качество	Calidad	Calidad	Qualidade
FILTER_TIME_ADDED	Age	Age	Temps ajouté	Hinzugefügt am	Tempo di acquisizione	획득 시간	添加时间	加入時間	Добавлено	Tiempo añadido	Tiempo añadido	Adquirido em
FILTER_BINDING	Binding	Binding	Raccourci	Bindung	Legatùra	귀속	绑定	綁定	Перс.	Vendajes	Vendajes	Vinculação
FILTER_EXPANSION	Expansion	Expansion	Extension	Erweiterung	Espansione	확장팩	资料片	資料片	Расширение	Expansión	Expansión	Expansão
FILTER_LEVEL	Level	Level	Niveau	Level	Livello	레벨	等级	等級	Уровень	Nivel	Nivel	Nível
FILTER_MARKER_ICON	Marker Icon	Marker Icon	Icône de marqueur de cible	Markersymbol	Icona del marcatore	징표	标记	標記圖示	Метка	Icono Marcador	Icono Marcador	Icone Marcador
FILTER_NAME_SEARCH	Name Search	Name Search	Recherche de nom	Namenssuche	Ricerca per Nome	이름 검색	名称搜寻	名稱搜尋	Поиск	Búsqueda por nombre	Búsqueda por nombre	Pesquisa por Nome
FILTER_TOOLTIP_SEARCH	Tooltip Search	Tooltip Search	Info-bulle de recherche	Tooltip Suche	Ricerca tooltip	툴팁 검색	提示搜索	提示搜尋	Всплывающий поиск			Busca na dica de ferramenta
FILTER_LIB_ITEM_SEARCH	(Advanced) LibItemSearch Query	(Advanced) LibItemSearch Query	(Avancé) Requête via LibItemSearch	(Erweitert) LibItemSearch Abfrage	(Avanzata) Query di ricerca LibItem	(고급) LibItemSearch 쿼리	(进阶)LibItemSearch查询	(進階)LibItemSearch查詢	(Доп.) LibItemSearch запрос			(Avançado) Pesquisa LibItemSearch
FILTER_SPECIFIC_ITEMS	Specific Items	Specific Items	Objet spécifique	Spezifische Gegenstände	Articoli specifici	특정 아이템	特定物品	特定物品	Спец. предметы	Objetos específicos	Objetos específicos	Itens específicos
FILTER_VALUES	Values	Values					值	值				
SUBFILTER_TYPE_ARMOR	Armor	Armour	Armure	Rüstung	Armatura	방어구	护甲	護甲	Броня	Armadura	Armadura	Armadura
SUBFILTER_TYPE_BATTLE_PET	Battle Pet	Battle Pet	Mascotte de combat	Kampfhaustiere	Mascotte da Battaglia	전투 애완동물	战斗宠物	戰寵	Питомцы	Mascota de duelo	Mascota de duelo	Mascote de batalha
SUBFILTER_TYPE_CONSUMABLE	Consumable	Consumable	Consommable	Verbrauchbares	Consumàbile	소모성	消耗品	消耗品	Расх. материал	Consumibles	Consumibles	Consumíveis
SUBFILTER_TYPE_CONTAINER	Container	Container	Conteneur	Container	Contenitore	가방	容器	容器	Сумки	Contenedor	Contenedor	Recipientes
SUBFILTER_TYPE_GEM	Gem	Gem	Gemme	Edelstein	Gemma	보석	宝石	寶石	Камни	Gema	Gema	Gemas
SUBFILTER_TYPE_GLYPH	Glyph	Glyph	Glyphe	Glyph	Glifo	문양	雕纹	雕紋	Символы	Glifo	Glifo	Glifos
SUBFILTER_TYPE_ITEM_ENHANCEMENT	Item Enhancement	Item Enhancement	Amélioration d'objet	Itemverbesserung	Potenziamenti oggetto	아이템 강화	物品强化	物品強化	Улуч. предмета	Objeto de Mejora	Objeto de Mejora	Aperfeiçoamentos de Itens
SUBFILTER_TYPE_KEY	Key	Key	Clé	Schlüssel	Chiave	열쇠	钥匙	鑰匙	Ключ	LLave	LLave	Chave
SUBFILTER_TYPE_MISCELLANEOUS	Miscellaneous	Miscellaneous	Divers	Verschiedenes	Varie	기타	杂项	雜項	Разное	Miscelánea	Miscelánea	Diversos
SUBFILTER_TYPE_REAGENT	Reagent	Reagent	Composant	Reagenz	Reagente	재료	试剂	試劑	Реагент	Componentes	Componentes	Mercadorias
SUBFILTER_TYPE_RECIPE	Recipe	Recipe	Recette	Rezept	Ricette	습득서	配方	配方	Рецепт	Recetas	Recetas	Receita
SUBFILTER_TYPE_PROJECTILE	Projectile	Projectile	Projectile	Projektil	Proiettile	발사체	发射物	發射物	Снаряд	Proyectiles	Proyectiles	Projéteis
SUBFILTER_TYPE_QUEST	Quest	Quest	Quête	Quest	Missione	퀘스트	任务	任務	Задание	Misión	Misión	Missão
SUBFILTER_TYPE_QUIVER	Quiver	Quiver	Carquois	Köcher	Faretra	화살통	箭袋	箭袋	Колчан	Carcaj	Carcaj	Aljava
SUBFILTER_TYPE_TRADE_GOODS	Trade Good	Trade Good	Marchandise	Handelswaren	Beni commerciali	직업용품	商品	商品	Хоз. товар	Bienes de Comercio	Bienes de Comercio	Mercadorias
SUBFILTER_TYPE_WEAPON	Weapon	Weapon	Arme	Waffe	Arma	무기	武器	武器	Оружие	Arma	Arma	Arma
SUBFILTER_EQUIP_LOCATION_HEAD	Head	Head	Tête	Kopf	Testa	머리	头部	頭部	Голова	Cabeza	Cabeza	Cabeça
SUBFILTER_EQUIP_LOCATION_NECK	Neck	Neck	Cou	Hals	Collo	목	颈部	頸部	Шея	Cuello	Cuello	Pescoço
SUBFILTER_EQUIP_LOCATION_SHOULDER	Shoulder	Shoulder	Épaule	Schulter	Spalle	어깨	肩部	肩部	Плечи	Hombro	Hombro	Ombro
SUBFILTER_EQUIP_LOCATION_BACK	Back	Back	Dos	Rücken	Schiena	등	斗篷	背部	Спина	Espalda	Espalda	Costas
SUBFILTER_EQUIP_LOCATION_CHEST	Chest	Chest	Torse	Brust	Torso	가슴	胸部	胸部	Грудь	Pecho	Pecho	Torso
SUBFILTER_EQUIP_LOCATION_SHIRT	Shirt	Shirt	Chemise	Hemd	Camicia	속옷	衬衫	襯衣	Рубашка	Camisa	Camisa	Camiseta
SUBFILTER_EQUIP_LOCATION_TABARD	Tabard	Tabard	Tabard	Wappenrock	Insegna	겉옷	战袍	外袍	Накидка	Tabardo	Tabardo	Tabardo
SUBFILTER_EQUIP_LOCATION_WRIST	Wrist	Wrist	Poignet	Handgelenk	Polsi	손목	手腕	手腕	Запястье	Muñeca	Muñeca	Pulsos
SUBFILTER_EQUIP_LOCATION_HANDS	Hands	Hands	Mains	Hände	Mani	손	手	手	Кисти	Manos	Manos	Mãos
SUBFILTER_EQUIP_LOCATION_WAIST	Waist	Waist	Ceinture	Taille	Fianchi	허리	腰部	腰部	Пояс	Cintura	Cintura	Cintura
SUBFILTER_EQUIP_LOCATION_LEGS	Legs	Legs	Pantalon	Beine	Gambe	다리	腿部	腿部	Ноги	Piernas	Piernas	Pernas
SUBFILTER_EQUIP_LOCATION_FEET	Feet	Feet	Pieds	Füße	Piedi	발	脚	腳	Обувь	Pies	Pies	Pés
SUBFILTER_EQUIP_LOCATION_FINGER	Finger	Finger	Doigt	Finger	Dito	손가락	手指	手指	Палец	Dedo	Dedo	Dedos
SUBFILTER_EQUIP_LOCATION_TRINKET	Trinket	Trinket	Bijou	Schmuck	Monile	장신구	饰品	飾品	Аксессуар	Abalorio	Abalorio	Berloques
SUBFILTER_EQUIP_LOCATION_OFF_HAND	Off-Hand	Off-Hand	Main gauche	Nebenhand	Mano secondaria	보조장비	副手	副手	Левая рука	Improvisado	Improvisado	Mão Secundária
SUBFILTER_EQUIP_LOCATION_RELIC	Relic	Relic	Relique	Relikt	Reliquia	유물	圣物	聖物	Реликвия	Reliquia	Reliquia	Relíquia
SUBFILTER_EQUIP_LOCATION_ONE_HAND	One-Handed	One-Handed	Arme à 1 main	Einhändig	Una Mano	한손	单手	單手	Одноручное	Una mano	Una mano	Uma Mão
SUBFILTER_EQUIP_LOCATION_TWO_HAND	Two-Handed	Two-Handed	Arme à 2 mains	Zweihändig	Due Mani	양손	双手	雙手	Двуручное	Dos manos	Dos manos	Duas Mãos
SUBFILTER_EQUIP_LOCATION_RANGED	Ranged	Ranged	Arme à distance	Fernkampf	A distanza	원거리	远程	遠程	Дальний бой	Rango	Rango	Longo Alcance
SUBFILTER_SUBTYPE_ARMOR_PLATE	Plate	Plate	Plaque	Platte	Piastre	판금	板甲	鎧甲	Латы	Placa	Placa	Placas
SUBFILTER_SUBTYPE_ARMOR_MAIL	Mail	Mail	Maille	Kette	Maglia	사슬	锁甲	鎖甲	Кольчуга	Malla	Malla	Malha
SUBFILTER_SUBTYPE_ARMOR_LEATHER	Leather	Leather	Cuir	Leder	Cuoio	가죽	皮甲	皮甲	Кожа	Cuero	Cuero	Couro
SUBFILTER_SUBTYPE_ARMOR_CLOTH	Cloth	Cloth	Tissu	Kleidung	Stoffa	천	布甲	布甲	Ткань	Tela	Tela	Tecido
SUBFILTER_SUBTYPE_ARMOR_COSMETIC	Cosmetic	Cosmetic	Cosmétique	Kosmetisch	Cosmetico	장식	造型	造型	Косметика	Cosmético	Cosmético	Cosmético
SUBFILTER_SUBTYPE_ARMOR_GENERIC	Generic	Generic	Générique	Generisch	Generica	포괄적	一般	一般	Общий	Generico	Generico	Genérico
SUBFILTER_SUBTYPE_ARMOR_SHIELDS	Shields	Shields	Bouclier	Schild	Scudo	방패	盾牌	盾牌	Щиты	Escudos	Escudos	Escudos
SUBFILTER_SUBTYPE_ARMOR_LIBRAMS	Librams	Librams	Librams	Librams	Incunabolo	고서	圣契	聖契	Весы	Librama	Librama	Incunábulo
SUBFILTER_SUBTYPE_ARMOR_IDOLS	Idols	Idols	Idoles	Idole	Idoli	우상	雕像	雕像	Идолы	Ídolos	Ídolos	Ídolos
SUBFILTER_SUBTYPE_ARMOR_TOTEMS	Totems	Totems	Totems	Totems	Totem	토템	图腾	圖騰	Тотемы	Tótems	Tótems	Totems
SUBFILTER_SUBTYPE_ARMOR_SIGILS	Sigils	Sigils	Sigiles	Siegel	Sigilli	인장	符印	符印	Сигилы	Sigilos	Sigilos	Sigílos
SUBFILTER_SUBTYPE_BATTLE_PET_HUMANOID	Humanoid	Humanoid	Humanoïdes	Menschlich	Umanoide	인간형	人形	人形生物	Гуманоид	Humanoide	Humanoide	Humanoide
SUBFILTER_SUBTYPE_BATTLE_PET_DRAGON	Dragon	Dragon	Dragon	Drache	Dragoide	용족	龙类	龍類	Дракон	Dragón	Dragón	Dragão
SUBFILTER_SUBTYPE_BATTLE_PET_FLYING	Flying	Flying	Volant	Fliegend	Volante	비행	飞行	飛行	Летающий	Volador	Volador	Voador
SUBFILTER_SUBTYPE_BATTLE_PET_UNDEAD	Undead	Undead	Mort-vivant	Untot	Non morta	언데드	亡灵	不死	Нежить	No muerto	No muerto	Morto-Vivo
SUBFILTER_SUBTYPE_BATTLE_PET_CRITTER	Critter	Critter	Bestiole	Kleintier	Animale	동물	小生物	小動物	Зверек	Bicho	Bicho	Bicho
SUBFILTER_SUBTYPE_BATTLE_PET_MAGICAL	Magical	Magical	Magique	Magisch	Magica	마법	魔法	魔法	Магический	Mágico	Mágico	Mágico
SUBFILTER_SUBTYPE_BATTLE_PET_ELEMENTAL	Elemental	Elemental	Elémentale	Elementar	Elementale	정령	元素	元素	Элементаль	Elemental	Elemental	Elemental
SUBFILTER_SUBTYPE_BATTLE_PET_BEAST	Beast	Beast	Bête	Biest	Bestiale	야수	野兽	野獸	Животное	Bestia	Bestia	Fera
SUBFILTER_SUBTYPE_BATTLE_PET_WATER	Water	Water	Aquatique	Wasser	Acquatica	물	水栖	水棲	Водный	Agua	Agua	Água
SUBFILTER_SUBTYPE_BATTLE_PET_MECHANICAL	Mechanical	Mechanical	Machine	Mechanisch	Meccanica	기계	机械	機械	Механизм	Mecánico	Mecánico	Meânico
SUBFILTER_SUBTYPE_CONSUMABLE_BOMBS_AND_DEVICES	Bombs and Devices	Bombs and Devices	Bombes et dispositifs	Bomben und Geräte	Esplosivi e congegni	폭발물과 장치	爆炸物与装置	爆裂物與裝置	Бомбы/устройства	Bombas y Dispositívos	Bombas y Dispositívos	Bombas e Dispositivos
SUBFILTER_SUBTYPE_CONSUMABLE_POTIONS	Potions	Potions	Potions	Tränke	Pozioni	물약	药水	藥水	Зелья	Pociones	Pociones	Poções
SUBFILTER_SUBTYPE_CONSUMABLE_ELIXIRS	Elixirs	Elixirs	Elixires	Elixire	Elisir	비약	药剂	藥劑	Эликсиры	Elixires	Elixires	Elixires
SUBFILTER_SUBTYPE_CONSUMABLE_FLASKS	Flasks	Flasks	Flacons	Flaschen	Tonico	영약	合剂	精煉藥劑	Настои	Vial	Vial	Frascos
SUBFILTER_SUBTYPE_CONSUMABLE_FOOD_AND_DRINK	Food & Drink	Food & Drink	Nourriture et boissons	Essen und Trinken	Cibo e bevande	음식과 음료	食物和饮料	食物和飲料	Еда/питьё	Comida y Bebida	Comida y Bebida	Comidas e Bebidas
SUBFILTER_SUBTYPE_CONSUMABLE_BANDAGES	Bandages	Bandages	Bandages	Bandagen	Benda	붕대	绷带	繃帶	Бинты	Vendajes	Vendajes	Bandagens
SUBFILTER_SUBTYPE_CONSUMABLE_VANTUS_RUNES	Vantus Runes	Vantus Runes	Runes de Vantus	Vantus Runen	Runa Vantus	반투스 룬	凡图斯符文	梵陀符文	Вант. руны	Runas Vantus	Runas Vantus	Runa Vantus
SUBFILTER_SUBTYPE_CONSUMABLE_OTHER	Other	Other	Autre	Anderes	Altro	그 외	其他	其他	Другое	Otro	Otro	Outros
SUBFILTER_SUBTYPE_CONSUMABLE_CONDUIT	Conduit	Conduit	Intermédiaire	Medien	Condotti	도관	导灵器	傳導器	Проводник			Conduite
SUBFILTER_SUBTYPE_CONTAINER_BAG	All-Purpose Bag	All-Purpose Bag	Sac tout usage	Tasche	Sacca	가방	背包	背包	Сумка	Mochila única	Mochila única	Bolsa 
SUBFILTER_SUBTYPE_CONTAINER_SOUL	Soul Bag	Soul Bag	Sac d'âmes	Seelentasche	Sacca per anime	영혼석 가방	灵魂袋	靈魂袋	Сумка душ	Bola de almas	Bola de almas	Bolsa de Almas
SUBFILTER_SUBTYPE_CONTAINER_HERB	Herb Bag	Herb Bag	Sac d'herbes	Kräutertasche	Sacca da erbalista	약초 가방	草药包	草藥包	Сумка травника	Bolsa de hierbas	Bolsa de hierbas	Bolsa de Herborismo
SUBFILTER_SUBTYPE_CONTAINER_ENCHANTING	Enchanting Bag	Enchanting Bag	Sac d'enchanteur	Verzauberungstasche	Sacca da incantatore	마법부여 가방	附魔包	附魔包	Сумка зачаровывателя	Bolsa de Encantamiento	Bolsa de Encantamiento	Bolsa de Encantamento
SUBFILTER_SUBTYPE_CONTAINER_ENGINEERING	Engineering Bag	Engineering Bag	Sac d'ingénieur	Ingenieurstasche	Sacca da ingegnere	기계공학 가방	工程包	工程包	Сумка инженера	Bolsa de Ingeniería	Bolsa de Ingeniería	Bolsa de Engenharia
SUBFILTER_SUBTYPE_CONTAINER_GEM	Gem Bag	Gem Bag	Sac de gemmes	Edelsteintasche	Sacca da orafo	보석 가방	宝石包	寶石包	Сумка ювелира	Bolsa de Gemas	Bolsa de Gemas	Bolsa de Gemas
SUBFILTER_SUBTYPE_CONTAINER_MINING	Mining Bag	Mining Bag	Sac de minerais	Bergbautasche	Sacca da minatore	채광 가방	矿石包	礦石包	Сумка шахтера	Bolsa de Minería	Bolsa de Minería	Bolsa de Mineração
SUBFILTER_SUBTYPE_CONTAINER_LEATHERWORKING	Leatherworking Bag	Leatherworking Bag	Sac de travailleur du cuir	Lederverarbeitungstasche	Sacca da conciatore	가죽세공 가방	制皮包	製皮包	Сумка снятия шкур	Bolsa de Peletería	Bolsa de Peletería	Bolsa de Couraria
SUBFILTER_SUBTYPE_CONTAINER_INSCRIPTION	Inscription Bag	Inscription Bag	Sac de caligraphe	Inschriftentasche	Sacca da runografo	주문각인 가방	铭文包	銘文包	Сумка начертателя	Bolsa de Inscripción	Bolsa de Inscripción	Bolsa de Escrivania
SUBFILTER_SUBTYPE_CONTAINER_TACKLE	Tackle Box	Tackle Box	Coffre à pêche	Angelkasten	Casseta da pescatore	낚시 가방	钓饵箱	釣餌箱	Ящик для снастей	Caja de aparejos	Caja de aparejos	Caixa de Pesca
SUBFILTER_SUBTYPE_CONTAINER_COOKING	Cooking Bag	Cooking Bag	Sac de cuisine	Kochtasche	Sacche da cuoco	요리 가방	烹饪包	烹飪包	Сумка повара	Bolsa de Cocina	Bolsa de Cocina	Bolsa de Culinária
SUBFILTER_SUBTYPE_GEM_INTELLECT	Intellect	Intellect	Intelligence	Intellekt	Intelletto	지능	智力	智力	Интеллект	Intelecto	Intelecto	Intelecto
SUBFILTER_SUBTYPE_GEM_AGILITY	Agility	Agility	Agilité	Agilität	Agilità	민첩	敏捷	敏捷	Ловкость	Agilidad	Agilidad	Agilidade
SUBFILTER_SUBTYPE_GEM_STRENGTH	Strength	Strength	Force	Stärke	Forza	힘	力量	力量	Сила	Fuerza	Fuerza	Força
SUBFILTER_SUBTYPE_GEM_STAMINA	Stamina	Stamina	Endurance	Ausdauer	Tempra	체력	耐力	耐力	Выносливость	Aguante	Aguante	Vigor
SUBFILTER_SUBTYPE_GEM_SPIRIT	Spirit	Spirit	Esprit	Geist	Spirito	영혼	精神	精神	Дух	Espíritu	Espíritu	Espírito
SUBFILTER_SUBTYPE_GEM_CRITICAL_STRIKE	Critical Strike	Critical Strike	Coût Critique	Kritischer Schlag	Indice di Critico	치명타	暴击	致命一擊	Критический удар	Golpe Crítico	Golpe Crítico	Golpe Crítico
SUBFILTER_SUBTYPE_GEM_MASTERY	Mastery	Mastery	Maîtrise	Meisterschaft	Maestria	특화	精通	精通	Искусность	Maestría	Maestría	Maestria
SUBFILTER_SUBTYPE_GEM_HASTE	Haste	Haste	Hâte	Tempo	Celerità	가속	急速	加速	Скорость	Celeridad	Celeridad	Aceleração
SUBFILTER_SUBTYPE_GEM_VERSATILITY	Versatility	Versatility	Polyvalence	Vielseitigkeit	Versatilità	유연성	全能	臨機應變	Универсальность	Versatilidad	Versatilidad	Versatilidade
SUBFILTER_SUBTYPE_GEM_OTHER	Other	Other	Autre	Anderes	Altro	그 외	其他	其他	Другое	Otro	Otro	Outro
SUBFILTER_SUBTYPE_GEM_MULTIPLE_STATS	Multiple Stats	Multiple Stats	Stats Multiples	Mehrere Attribute	Statistiche Multiple	다중 능력치	多项属性	多項屬性	Неск. характеристик	Estadísticas Várias	Estadísticas Várias	Múltiplos Atributos
SUBFILTER_SUBTYPE_GEM_ARTIFACT_RELIC	Artifact Relic	Artefact Relic	Relique d'artefact	Artefaktrelikt	Reliquia dell'Artefatto	유물 보석	神兵圣物	神兵聖物	Реликвия артефакта	Reliquia de Artefacto	Reliquia de Artefacto	Relíquia de Artefato
SUBFILTER_SUBTYPE_GLYPH_WARRIOR	Warrior	Warrior	Guerrier	Krieger	Guerriero	전사	战士	戰士	Воин	Guerrero	Guerrero	Guerreiro
SUBFILTER_SUBTYPE_GLYPH_PALADIN	Paladin	Paladin	Paladin	Paladin	Paladino	성기사	圣骑士	聖騎士	Паладин	Paladin	Paladin	Paladino
SUBFILTER_SUBTYPE_GLYPH_HUNTER	Hunter	Hunter	Chasseur	Jäger	Cacciatore	사냥꾼	猎人	獵人	Охотник	Cazador	Cazador	Caçador
SUBFILTER_SUBTYPE_GLYPH_ROGUE	Rogue	Rogue	Voleur	Schurke	Ladro	도적	潜行者	盜賊	Разбойник	Pícaro	Pícaro	Ladino
SUBFILTER_SUBTYPE_GLYPH_PRIEST	Priest	Priest	Prêtre	Priester	Sacerdote	사제	牧师	牧師	Жрец	Sacerdote	Sacerdote	Sacerdote
SUBFILTER_SUBTYPE_GLYPH_DEATH_KNIGHT	Death Knight	Death Knight	Chevalier de la mort	Todesritter	Cavaliere della Morte	죽음의 기사	死亡骑士	死亡騎士	Рыцарь смерти	Caballero de la Muerte	Caballero de la Muerte	Cavaleiro da Morte
SUBFILTER_SUBTYPE_GLYPH_SHAMAN	Shaman	Shaman	Chaman	Schamane	Sciamano	주술사	萨满	薩滿	Шаман	Chamán	Chamán	Xamã
SUBFILTER_SUBTYPE_GLYPH_MAGE	Mage	Mage	Mage	Magier	Mago	마법사	法师	法師	Маг	Mago	Mago	Mago
SUBFILTER_SUBTYPE_GLYPH_WARLOCK	Warlock	Warlock	Démoniste	Hexenmeister	Stregone	흑마법사	术士	術士	Чернокнижник	Brujo	Brujo	Bruxo
SUBFILTER_SUBTYPE_GLYPH_MONK	Monk	Monk	Moine	Mönch	Monaco	수도사	武僧	武僧	Монах	Monje	Monje	Monge
SUBFILTER_SUBTYPE_GLYPH_DRUID	Druid	Druid	Druide	Druide	Druido	드루이드	德鲁伊	德魯伊	Друид	Druida	Druida	Druida
SUBFILTER_SUBTYPE_GLYPH_DEMON_HUNTER	Demon Hunter	Demon Hunter	Chasseur de démon	Dämonenjäger	Cacciatore di Demoni	악마 사냥꾼	恶魔猎手	惡魔獵人	Охотник на демонов	Cazador de Demonios	Cazador de Demonios	Caçador de Demônios
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_HEAD	Head	Head	Tête	Kopf	Testa	머리	头部	頭部	Голова	Cabeza	Cabeza	Cabeça
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_NECK	Neck	Neck	Cou	Hals	Collo	목	颈部	頸部	Шея	Cuello	Cuello	Pescoço
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_SHOULDER	Shoulder	Shoulder	Epaules	Schulter	Spalle	어깨	肩部	肩部	Плечи	Hombro	Hombro	Ombros
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_CLOAK	Cloak	Cloak	Cape	Umhang	Schiena	등	背部	背部	Плащ	Capa	Capa	Capa
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_CHEST	Chest	Chest	Torse	Brust	Torso	가슴	胸部	胸部	Грудь	Pecho	Pecho	Torso
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_WRIST	Wrist	Wrist	Poignets	Handgelenk	Polsi	손목	手腕	手腕	Запястья	Muñeca	Muñeca	Pulsos
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_HANDS	Hands	Hands	Mains	Hände	Mani	손	手	手	Кисти	Manos	Manos	Mãos
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_WAIST	Waist	Waist	Ceinture	Taille	Fianchi	허리	腰部	腰部	Пояс	Cintura	Cintura	Cintura
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_LEGS	Legs	Legs	Jambes	Beine	Gambe	다리	腿部	腿部	Ноги	Piernas	Piernas	Pernas
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_FEET	Feet	Feet	Pieds	Füße	Piedi	발	脚	腳	Обувь	Pies	Pies	Pés
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_FINGER	Finger	Finger	Doigts	Finger	Dito	손가락	手指	手指	Палец	Dedo	Dedo	Dedos
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_ONE_HAND	One-Handed Weapons	One-Handed Weapons	Armes à une main	Einhandwaffen	Arma	한손 무기	单手武器	單手武器	Одноручное	Armas de una mano	Armas de una mano	Armas de Uma Mão
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_TWO_HAND	Two-Handed Weapons	Two-Handed Weapons	Armes à deux mains	Zweihandwaffen	Arma a due mani	양손 무기	双手武器	雙手武器	Двуручное	Armas de dos manos	Armas de dos manos	Armas de Duas Mãos
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_SHIELD_OFF_HAND	Shield/Offhand	Shield/Offhand	Bouclier/Main gauche	Schild/Nebenhand	Scudo/Mano secondaria	방패/보조무기	盾牌/副手	盾牌/副手	Щит/левая рука	Escudos/Improvisados	Escudos/Improvisados	Escudo/Mão Secundária
SUBFILTER_SUBTYPE_ITEM_ENHANCEMENT_MISCELLANEOUS	Misc	Misc	Divers	Verschiedenes	Varie	기타	杂项	雜項	Разное	Misce	Misce	Diversos
SUBFILTER_SUBTYPE_KEY_KEY	Key	Key	Clé	Schlüssel	Chiave	열쇠	钥匙	鑰匙	Ключ	LLave	LLave	Chave
SUBFILTER_SUBTYPE_KEY_LOCKPICK	Lockpick	Lockpick	Crochetage	Dietrich	Grimaldello	자물쇠	开锁器	開鎖器	Отмычка	Ganzúa	Ganzúa	Gazua
SUBFILTER_SUBTYPE_MISCELLANEOUS_JUNK	Junk	Junk	Camelotte	Schrott	Cianfrusaglia	잡동사니	垃圾	垃圾	Мусор	Inútil	Inútil	Lixo
SUBFILTER_SUBTYPE_MISCELLANEOUS_REAGENTS	Spell Reagents	Spell Reagents	Composant de sort	Zauberreagenzien	Reagente	주문 재료	施法材料	施法材料	Для заклинаний	Componentes de Conjuros	Componentes de Conjuros	Mercadorias de Conjuração
SUBFILTER_SUBTYPE_MISCELLANEOUS_COMPANION_PETS	Companion Pets	Companion Pets	Mascottes	Begleithaustiere	Mascotte	전투 애완동물	宠物伙伴	寵物夥伴	Питомцы	Mascotas	Mascotas	Mascotes
SUBFILTER_SUBTYPE_MISCELLANEOUS_HOLIDAY	Holiday	Holiday	Vacances	Feiertag	Festivo	이벤트	节庆用品	節慶用品	Праздничные	Fiesta	Fiesta	Feriado
SUBFILTER_SUBTYPE_MISCELLANEOUS_OTHER	Other	Other	Autre	Anderes	Varie	그 외	其他	其他	Другое	Otro	Otro	Outros
SUBFILTER_SUBTYPE_MISCELLANEOUS_MOUNT	Mount	Mount	Monture	Reittier	Cavalcature	탈것	坐骑	坐騎	Транспорт	Montura	Montura	Montaria
SUBFILTER_SUBTYPE_MISCELLANEOUS_MOUNT_EQUIPMENT	Mount Equipment	Mount Equipment	Equipement de monture	Reittierausrüstung	Equipaggiamento per Cavalcatura	탈것 장비	坐骑装备	坐騎裝備	Добавление трапспорта	Equipo de Montura	Equipo de Montura	Equipamento de Montaria
SUBFILTER_SUBTYPE_RECIPE_BOOK	Book	Book	Livre	Buch	Libro	책	书籍	書籍	Книга	Libro	Libro	Livro
SUBFILTER_SUBTYPE_RECIPE_LEATHERWORKING	Leatherworking	Leatherworking	Travail du cuir	Lederverarbeitung	Conciatra	가죽세공	制皮	製皮	Снятие шкур	Peletería	Peletería	Couraria
SUBFILTER_SUBTYPE_RECIPE_TAILORING	Tailoring	Tailoring	Coûture	Schneidern	Sartoria	주문각인	裁缝	裁縫	Портняжное дело	Sastrería	Sastrería	Alfaiataria
SUBFILTER_SUBTYPE_RECIPE_ENGINEERING	Engineering	Engineering	Ingénierie	Ingenieurwissenschaft	Ingegneria	기계공학	工程学	工程學	Инженерное дело	Ingeniería	Ingeniería	Engenharia
SUBFILTER_SUBTYPE_RECIPE_BLACKSMITHING	Blacksmithing	Blacksmithing	Forge	Schmiedekunst	Forgiatura	대장기술	锻造	鍛造	Кузнечное дело	Herrería	Herrería	Ferraria
SUBFILTER_SUBTYPE_RECIPE_COOKING	Cooking	Cooking	Cuisine	Kochen	Cucina	요리	烹饪	烹飪	Кулинария	Cocina	Cocina	Culinária
SUBFILTER_SUBTYPE_RECIPE_ALCHEMY	Alchemy	Alchemy	Alchimie	Alchemie	Alchimia	연금술	炼金术	煉金術	Алхимия	Alquímia	Alquímia	Alquimia
SUBFILTER_SUBTYPE_RECIPE_FIRST_AID	First Aid	First Aid	Secourisme	Erste Hilfe	Primo Soccorso	응급치료	急救	急救	Первая помощь	Primeros Auxilios	Primeros Auxilios	Primeiros Socorros
SUBFILTER_SUBTYPE_RECIPE_ENCHANTING	Enchanting	Enchanting	Enchantements	Verzauberkunst	Incantamento	마법부여	附魔	附魔	Наложение чар	Encantamiento	Encantamiento	Encantamento
SUBFILTER_SUBTYPE_RECIPE_FISHING	Fishing	Fishing	Pêche	Angeln	Pesca	낚시	钓鱼	釣魚	Рыбная ловля	Pesca	Pesca	Pescaria
SUBFILTER_SUBTYPE_RECIPE_JEWELCRAFTING	Jewelcrafting	Jewelcrafting	Joaillerie	Juwelenschleifen	Oreficeria	보석세공	珠宝加工	珠寶設計	Ювелирное дело	Joyería	Joyería	Joalheria
SUBFILTER_SUBTYPE_RECIPE_INSCRIPTION	Inscription	Inscription	Caligraphie	Inschriftenkunde	Runografia	주문각인	铭文	銘文	Начертание	Inscripción	Inscripción	Escrivania
SUBFILTER_SUBTYPE_PROJECTILE_ARROW	Arrow	Arrow	Flèche	Pfeil		화살	箭	箭	Стрела	Flecha	Flecha	Flecha
SUBFILTER_SUBTYPE_PROJECTILE_BULLET	Bullet	Bullet	Balle	Kugel		탄약	子弹	子彈	Пуля	Bala	Bala	Bala
SUBFILTER_SUBTYPE_QUIVER_QUIVER	Quiver	Quiver	Carquois	Köcher		화살통	箭袋	箭袋	Колчан	Carcaj	Carcaj	Aljava
SUBFILTER_SUBTYPE_QUIVER_AMMO_POUCH	Ammo Pouch	Ammo Pouch	Pochette de munitions	Munitionsbeutel		탄약 주머니	弹药袋	彈藥袋	Боеприпасы	Cartuchera para municiones	Cartuchera para municiones	Saco de Munição
SUBFILTER_SUBTYPE_TRADE_GOODS_PARTS	Parts	Parts	Pièces	Teile	Componente	부품	零件	零件	Запчасти	Partes	Partes	Partes
SUBFILTER_SUBTYPE_TRADE_GOODS_JEWELCRAFTING	Jewelcrafting	Jewelcrafting	Joaillerie	Juwelenschleifen	Oreficeria	보석세공	珠宝加工	珠寶設計	Ювелирное дело	Joyería	Joyería	Joalheria
SUBFILTER_SUBTYPE_TRADE_GOODS_CLOTH	Cloth	Cloth	Tissu	Kleidung	Stoffa	천	布料	布料	Ткань	Tela	Tela	Tecido
SUBFILTER_SUBTYPE_TRADE_GOODS_LEATHER	Leather	Leather	Cuir	Lederverarbeitung	Pelle	가죽	皮革	皮革	Кожа	Cuero	Cuero	Couro
SUBFILTER_SUBTYPE_TRADE_GOODS_METAL_AND_STONE	Metal & Stone	Metal & Stone	Métal et minerais	Metall & Stein	Metallo e pietra	금속 & 돌	金属与石头	金屬與石頭	Металл/камень	Metal y Piedra	Metal y Piedra	Metal e Pedra
SUBFILTER_SUBTYPE_TRADE_GOODS_COOKING	Cooking	Cooking	Cuisine	Kochen	Cucina	요리	烹饪	烹飪	Кулинария	Cocina	Cocina	Culinária
SUBFILTER_SUBTYPE_TRADE_GOODS_HERB	Herb	Herb	Herbes	Kräuter	Erba	약초	草药	草藥	Травничество	Hierba	Hierba	Erva
SUBFILTER_SUBTYPE_TRADE_GOODS_ELEMENTAL	Elemental	Elemental	Elémentaires	Elementar	Elementale	원소	元素材料	元素材料	Стихия	Elemental	Elemental	Elemental
SUBFILTER_SUBTYPE_TRADE_GOODS_ENCHANTING	Enchanting	Enchanting	Enchantements	Verzauberkunst	Incantamento	마법부여	附魔	附魔	Наложение чар	Encantamiento	Encantamiento	Encantamento
SUBFILTER_SUBTYPE_TRADE_GOODS_INSCRIPTION	Inscription	Inscription	Caligraphie	Inschriftenkunde	Runografia	주문각인	铭文	銘文	Начертание	Inscripción	Inscripción	Escrivania
SUBFILTER_SUBTYPE_TRADE_GOODS_OTHER	Other	Other	Autre	Andere	Altro	그 외	其他	其他	Другое	Otro	Otro	Outros
SUBFILTER_SUBTYPE_WEAPON_AXES	Axes	Axes	Hâches	Äxte	Asce	도끼	斧	斧	Топоры	Hachas	Hachas	Machados
SUBFILTER_SUBTYPE_WEAPON_MACES	Maces	Maces	Masses	Keulen	Mazze	둔기	锤	錘	Булавы	Mazas	Mazas	Maças
SUBFILTER_SUBTYPE_WEAPON_SWORDS	Swords	Swords	Epées	Schwerter	Spade	도검	剑	劍	Мечи	Espadas	Espadas	Espadas
SUBFILTER_SUBTYPE_WEAPON_DAGGERS	Daggers	Daggers	Dagues	Dolche	Pugnali	단검	匕首	匕首	Кинжалы	Dagas	Dagas	Adagas
SUBFILTER_SUBTYPE_WEAPON_POLEARMS	Polearms	Polearms	Armes d'haste	Stangenwaffen	Armi ad asta	장창	长柄	長柄	Древковое	Varas	Varas	Arma de Haste
SUBFILTER_SUBTYPE_WEAPON_FIST	Fist Weapons	Fist Weapons	Armes de pugilat	Faustwaffen	Tirapugni	장착무기	拳套	拳套	Кистевое	Armas de puño	Armas de puño	Arma de Punho
SUBFILTER_SUBTYPE_WEAPON_GLAIVES	Warglaives	Warglaives	Glèves de guerre	Kriegsgleven	Lame da Guerra	전투검	战刃	戰刃	Боевые клинки	Guijas de Guerra	Guijas de Guerra	Glaives de Guerra
SUBFILTER_SUBTYPE_WEAPON_WANDS	Wands	Wands	Baguettes	Zauberstäbe	Bacchette	마법봉	魔杖	魔杖	Жезлы	Varitas	Varitas	Varinhas
SUBFILTER_SUBTYPE_WEAPON_STAVES	Staves	Staves	Bâtons	Stäbe	Bastone	지팡이	法杖	法杖	Посохи	Bastones	Bastones	Cajados
SUBFILTER_SUBTYPE_WEAPON_BOWS	Bows	Bows	Arcs	Bögen	Archi	활	弓	弓	Луки	Arcos	Arcos	Arcos
SUBFILTER_SUBTYPE_WEAPON_CROSSBOWS	Crossbows	Crossbows	Arbalètes	Armbrüste	Balestre	석궁	弩	弩	Арбалет	Ballestas	Ballestas	Bestas
SUBFILTER_SUBTYPE_WEAPON_GUNS	Guns	Guns	Fusils	Pistolen	Armi da Fuoco	총	枪械	槍械	Ружьё	Armas de fuego	Armas de fuego	Armas de Fogo
SUBFILTER_SUBTYPE_WEAPON_THROWN	Thrown	Thrown	Jeté	Wurfwaffen	Armi da Lancio	투척	投掷	投擲	Метательное	Arrojadizo	Arrojadizo	Arremesso
SUBFILTER_SUBTYPE_WEAPON_FISHING_POLES	Fishing Poles	Fishing Poles	Cannes à pêche	Angelruten	Canne da pesca	낚싯대	鱼竿	魚竿	Удочки	Cañas de pescar	Cañas de pescar	Vara de pescar
SUBFILTER_SUBTYPE_WEAPON_MISCELLANEOUS	Miscellaneous	Miscellaneous	Divers	Verschiedenes	Altro	기타	杂项	雜項	Разное	Miscelánea	Miscelánea	Diversos
SUBFILTER_STATS_STAMINA	Stamina	Stamina	Endurance	Ausdauer	Tempra	체력	耐力	耐力	Выносливость	Aguante	Aguante	Vigor
SUBFILTER_STATS_STRENGTH	Strength	Strength	Force	Stärke	Forza	힘	力量	力量	Сила	Fuerza	Fuerza	Força
SUBFILTER_STATS_AGILITY	Agility	Agility	Agilité	Beweglichkeit	Agilità	민첩	敏捷	敏捷	Ловкость	Agilidad	Agilidad	Agilidade
SUBFILTER_STATS_INTELLECT	Intellect	Intellect	Intelligence	Intellekt	Intelletto	지능	智力	智力	Интеллект	Intelecto	Intelecto	Intelecto
SUBFILTER_STATS_CRITICAL_STRIKE	Critical Strike	Critical Strike	Coût critique	Kritische Trefferchance	Indice di Critico	치명타	暴击	致命一擊	Крит. удар	Golpe Crítico	Golpe Crítico	Golpe Crítico
SUBFILTER_STATS_HASTE	Haste	Haste	Hâte	Tempo	Celerità	가속	急速	加速	Скорость	Celeridad	Celeridad	Aceleração
SUBFILTER_STATS_MASTERY	Mastery	Mastery	Maîtrise	Meisterschaft	Maestria	특화	精通	精通	Искусность	Maestría	Maestría	Maestria
SUBFILTER_STATS_VERSATILITY	Versatility	Versatility	Polyvalence	Vielseitigkeit	Versatilità	유연성	全能	臨機應變	Универсальность	Versatilidad	Versatilidad	Versatilidade
SUBFILTER_STATS_SPEED	Speed	Speed	Vitesse	Geschwindigkeit	Velocità	이동속도	速度	速度	Скор. передвижения	Velocidad	Velocidad	Velocidade
SUBFILTER_STATS_INDESTRUCTIBLE	Indestructible	Indestructible	Indestructible	Unzerstörbar	Indistruttibile	파괴 불가	坚固	永不磨損	Броня	Indestructible	Indestructible	Indestrutível
SUBFILTER_STATS_LEECH	Leech	Leech	Vol de vie	Lebensraub	Ritorno vitale	생기흡수	吸血	汲取	Самоисцеление	Chupasangre	Chupasangre	Sorver
SUBFILTER_STATS_AVOIDANCE	Avoidance	Avoidance	Evitement	Vermeidung	Elusione	회피	躲闪	迴避	Узбегание	Evasión	Evasión	Evasão
SUBFILTER_QUALITY_HEIRLOOM	Heirloom	Heirloom	Héritage	Erbstück	Cimeli	계승	传家宝	傳家寶	Наследие	Reliquia de familia	Reliquia de familia	Herança
SUBFILTER_QUALITY_ARTIFACT	Artifact	Artefact	Artéfacte	Artefakt	Arterfatto	유물	神器	神器	Артефакт	Artefacto	Artefacto	Artefato
SUBFILTER_QUALITY_LEGENDARY	Legendary	Legendary	Légendaire	Legendär	Leggendario	전설	传说	傳奇	Легендарное	Legendario	Legendario	Lendário
SUBFILTER_QUALITY_EPIC	Epic	Epic	Epique	Episch	Epico	영웅	史诗	史詩	Эпичное	Épico	Épico	Épico
SUBFILTER_QUALITY_RARE	Rare	Rare	Rare	Selten	Raro	희귀	精良	精良	Редкое	Raro	Raro	Raro
SUBFILTER_QUALITY_UNCOMMON	Uncommon	Uncommon	Peu commun	Ungewöhnlich	Pregiato	고급	良好	良好	Необычное	Poco común	Poco común	Incomum
SUBFILTER_QUALITY_COMMON	Common	Common	Commun	Gewöhnlich	Comune	일반	普通	普通	Обычное	Común	Común	Comum
SUBFILTER_QUALITY_POOR	Poor	Poor	Mauvaise	Plunder	Scarso	하급	粗劣	粗劣	Хлам	Pobre	Pobre	Pobre
SUBFILTER_TIME_SECOND_SHORT	Sec	Sec	Sec	Sek.	Sec	초	秒	秒	сек	Seg	Seg	Seg
SUBFILTER_TIME_SECONDS	Seconds	Seconds	Secondes	Sekunden	Secondi	초	秒	秒	секунд	Segundos	Segundos	Segundos
SUBFILTER_TIME_SECONDS_SHORT	Secs	Secs	Secs	Sek.	Sec.	초	秒	秒	сек.	Segs	Segs	Segs
SUBFILTER_TIME_MINUTE_SHORT	Min	Min	Min	Min.	Min	분	分	分	мин.	Min	Min	Min
SUBFILTER_TIME_MINUTES	Minutes	Minutes	Minutes	Minuten	Minuti	분	分钟	分鐘	минут	Minutos	Minutos	Minutos
SUBFILTER_TIME_MINUTES_SHORT	Mins	Mins	Mins	Min.	Min	분	分	分	мин.	Mins	Mins	Mins
SUBFILTER_TIME_HOUR_SHORT	Hour	Hour	Heure	Stunde	Ore	시간	小时	小時	час	Hora	Hora	Hora
SUBFILTER_TIME_HOURS	Hours	Hours	Heures	Stunden	Ore	시간	小时	小時	часов	Horas	Horas	Horas
SUBFILTER_TIME_HOURS_SHORT	Hrs	Hrs	H	Std.	O	시간	小时	小時	ч.	Hrs	Hrs	Hrs
SUBFILTER_TIME_DAY_SHORT	Day	Day	Jour	Tag	Giorno	일	天	天	день	Día	Día	Dia
SUBFILTER_TIME_DAYS	Days	Days	Jours	Tage	Giorni	일	天	天	дней	Días	Días	Dias
SUBFILTER_TIME_DAYS_SHORT	Days	Days	Jours	Tage	Giorni	일	天	天	дн.	Días	Días	Dias
SUBFILTER_TIME_WEEK_SHORT	Week	Week	Semaine	Woche	Settimana	주	周	週	неделя	Semana	Semana	Semana
SUBFILTER_TIME_WEEKS	Weeks	Weeks	Semaines	Wochen	Settimane	주	周	週	недель	Semanas	Semanas	Semanas
SUBFILTER_TIME_WEEKS_SHORT	Wks	Wks	Sems	Wo.	Set.	주	周	週	н.	Semanas	Semanas	Semanas
SUBFILTER_TIME_MONTH_SHORT	Mnth	Mnth	Mois	Mon.	Set	개월	月	月	месяц	Mes	Mes	Mes
SUBFILTER_TIME_MONTHS	Months	Months	Mois	Monate	Mesi	개월	月	月	месяцев	Meses	Meses	Meses
SUBFILTER_TIME_MONTHS_SHORT	Mths	Mths	M	Mon.	Mesi	개월	月	月	мес.	Meses	Meses	Meses
SUBFILTER_TIME_YEAR_SHORT	Year	Year	Année	Jahr	Anno	년	年	年	год	Año	Año	Ano
SUBFILTER_TIME_YEARS	Years	Years	Années	Jahre	Anni	년	年	年	лет	Años	Años	Anos
SUBFILTER_TIME_YEARS_SHORT	Yrs	Yrs	an	J.	A	년	年	年	г.	Años	Años	Anos
SUBFILTER_BINDING_NONE	None	None	Aucun	Keine	Nessuno	없음	无	無	нет	Ninguno	Ninguno	Nenhum
SUBFILTER_BINDING_ON_EQUIP	Bind on Equip	Bind on Equip	Lié quand équipé	Beim Anlegen gebunden	Si vincola all'equipaggiamento	착용 시 귀속	装备后绑定	裝備後	Становится персональным при надевании	Se liga al equipar	Se liga al equipar	Vincula-se ao Equipar
SUBFILTER_BINDING_ON_EQUIP_SHORT	Equip	Equip	Equipé	Anlegen	Equip	착귀	装绑	裝綁	Экипировать	Equipo	Equipo	Equip
SUBFILTER_BINDING_ON_PICKUP	Bind on Pickup	Bind on Pickup	Lié quand ramassé	Beim Aufheben gebunden	Si vincola alla raccolta	획득 시 귀속	拾取后绑定	拾取後	Становится персональным при получении	Se liga al recoger	Se liga al recoger	Vincula-se ao Recolher
SUBFILTER_BINDING_ON_PICKUP_SHORT	Pickup	Pickup	Ramassé	Aufheben	Raccolta	획귀	拾绑	拾綁	Подобрать	Recoger	Recoger	Recolhido
SUBFILTER_BINDING_ON_USE	Bind on Use	Bind on Use	Lié quand utilisé	Bei Benutzung gebunden	Si vincola all'uso	사용 시 귀속	使用后绑定	使用後	Становится персональным при использовании	Se liga al usar	Se liga al usar	Vincula-se ao Usar
SUBFILTER_BINDING_ON_USE_SHORT	Use	Use	Utilisé	Benutzen	Uso	사용	用绑	用綁	Исп.	Usar	Usar	Usar
SUBFILTER_BINDING_SOULBOUND	Soulbound	Soulbound	Lié au compte	Seelengebunden	Vincolato	계정 귀속	灵魂绑定	靈魂綁定	Персональный	Ligado al alma	Ligado al alma	Vinculado
SUBFILTER_BINDING_SOULBOUND_SHORT	Bound	Bound	Lié	Gebunden	Vincolato	계귀	绑定	綁定		Ligado	Ligado	Vinculado
SUBFILTER_EXPANSION_WOW	World of Warcraft	World of Warcraft		World of Warcraft		월드 오브 워크래프트						
SUBFILTER_EXPANSION_WOW_SHORT	WoW	WoW				오리						
SUBFILTER_EXPANSION_TBC	The Burning Crusade	The Burning Crusade	The Burning Crusade	The Burning Crusade	The Burning Crusade	불타는 성전	燃烧的远征	燃燒的遠征	The Burning Crusade	The Burning Crusade	The Burning Crusade	A Crusada Ardente
SUBFILTER_EXPANSION_TBC_SHORT	TBC	TBC	TBC	TBC	TBC	불성	远征	遠征	TBC	TBC	TBC	TBC
SUBFILTER_EXPANSION_WOTLK	Wrath of the Lich King	Wrath of the Lich King	Wrath of the Lich King	Wrath of the Lich King	Wrath of the Lich King	리치왕의 분노	巫妖王之怒	巫妖王之怒	Wrath of the Lich King	Wrath of the Lich King	Wrath of the Lich King	A Fúria do Lich Rei
SUBFILTER_EXPANSION_WOTLK_SHORT	Wrath	Wrath	Wrath	Wrath	Wrath	리분	巫妖王	巫妖王	Lich King	Wrath	Wrath	Wrath
SUBFILTER_EXPANSION_CATA	Cataclysm	Cataclysm	Cataclysm	Cataclysm	Cataclysm	대격변	大地的裂变	浩劫與重生	Cataclysm	Cataclysm	Cataclysm	Cataclismo
SUBFILTER_EXPANSION_CATA_SHORT	Cata	Cata	Cata	Cata	Cata	격변	大裂变	浩劫	Cataclysm	Cata	Cata	Cata
SUBFILTER_EXPANSION_MOP	Mists of Pandaria	Mists of Pandaria	Mists of Pandaria	Mists of Pandaria	Mists of Pandaria	판다리아의 안개	熊猫人之谜	潘達利亞迷霧	Mists of Pandaria	Mists of Pandaria	Mists of Pandaria	Brumas de Pandaria
SUBFILTER_EXPANSION_MOP_SHORT	MoP	MoP	MoP	MoP	MoP	판다	熊猫	潘達	MoP	MoP	MoP	MoP
SUBFILTER_EXPANSION_WOD	Warlords of Draenor	Warlords of Draenor	Warlords of Draenor	Warlords of Draenor	Warlords of Draenor	드레노어의 전쟁군주	德拉诺之王	德拉諾之霸	Warlords of Draenor	Warlords of Draenor	Warlords of Draenor	Senhores da Guerra de Draenor
SUBFILTER_EXPANSION_WOD_SHORT	WoD	WoD	WoD	WoD	WoD	드군	德拉诺	德拉諾	WoD	WoD	WoD	WoD
SUBFILTER_EXPANSION_LEGION	Legion	Legion	Legion	Legion	Legion	군단	军团再临	軍臨天下	Legion	Legion	Legion	Legion
SUBFILTER_EXPANSION_LEGION_SHORT	Legion	Legion	Legion	Legion	Legion	군단	军团	軍臨	Legion	Legion	Legion	Legion
SUBFILTER_EXPANSION_BFA	Battle for Azeroth	Battle for Azeroth	Battle for Azeroth	Battle for Azeroth	Battle for Azeroth	격전의 아제로스	争霸艾泽拉斯	決戰艾澤拉斯	Battle for Azeroth	Battle for Azeroth	Battle for Azeroth	Batalha por Azeroth
SUBFILTER_EXPANSION_BFA_SHORT	BfA	BfA	BfA	BfA	BfA	격아	争霸	決戰	BfA	BfA	BfA	BfA
SUBFILTER_EXPANSION_SHADOW	Shadowlands	Shadowlands	Shadowlands	Shadowlands	Shadowlands	어둠땅	暗影国度	暗影之境	Shadowlands	Shadowlands	Shadowlands	Shadowlands
SUBFILTER_EXPANSION_SHADOW_SHORT	SL	SL	SL	SL		둠땅	暗影	暗影				
SUBFILTER_EXPANSION_DRAGONFLIGHT	Dragonflight	Dragonflight	Dragonflight	Dragonflight		용군단	巨龙时代	巨龍崛起				
SUBFILTER_EXPANSION_DRAGONFLIGHT_SHORT	DF	DF	DF	DF		용군	巨龙	巨龍				
SUBFILTER_EXPANSION_WAR_WITHIN	The War Within	The War Within				내부 전쟁	地心之战	地心之戰				
SUBFILTER_EXPANSION_WAR_WITHIN_SHORT	TWW	TWW				내전	地心	地心				
SUBFILTER_EXPANSION_MIDNIGHT	Midnight	Midnight				한밤	至暗之夜	至暗之夜				
SUBFILTER_EXPANSION_MIDNIGHT_SHORT	MN	MN				한밤	暗夜	暗夜				
SUBFILTER_EXPANSION_LAST_TITAN	The Last Titan	The Last Titan				최후의 티탄	最后的泰坦	最後的泰坦				
SUBFILTER_EXPANSION_LAST_TITAN_SHORT	TLT	TLT				티탄	泰坦	泰坦				
SUBFILTER_LEVEL_ITEM_LEVEL	Item Level	Item Level	Niveau d'objet	Gegenstandslevel	Livello Oggetto	아이템 레벨	物品等级	物品等級	Ур. предмета	Nivel de objeto	Nivel de objeto	Nível de Item
SUBFILTER_LEVEL_REQUIRED_LEVEL	Required Level	Required Level	Niveau requis	Benötigtes Level	Richied il livello	착용 레벨	需求等级	需求等級	Треб. уровень	Nivel necesario	Nivel necesario	Nível Necessário
SUBFILTER_MARKER_ICON_NONE	No Marker Icon	No Marker Icon	Aucun	Keines	Nessuno	아이콘 표시 없음	无	無	нет	Ninguno	Ninguno	Nenhum
SUBFILTER_SPECIFIC_ITEMS_ID	ID	ID	ID	ID	ID	ID	ID	ID	ID	ID	ID	ID
SUBFILTER_SPECIFIC_ITEMS_NAME	Name	Name	Nom	Name	Nome	이름	名称	名稱	Имя	Nombre	Nombre	Nome
CONFIG_APPEARANCE	Appearance	Appearance	Apparence	Aussehen	Aspetti	외형	外观	外觀	Внешность	Apariencia	Apariencia	Aparência
CONFIG_FEATURES	Features	Features	Caractéristiques 	Eigenschaften		특징	功能	功能				Características
CONFIG_LIST	List View	List View	Voir la liste	Listen Ansicht		목록보기	列表视图	列表視圖				Lista
CONFIG_GRID	Grid View	Grid View	Voir la grille	Rasterdarstellung		격자보기	网格视图	網格視圖				Gride
CONFIG_BEHAVIOR	Behavior	Behavior	Comportement	Verhalten	Comportamento	동작	动作	動作	Поведение	Comportamiento	Comportamiento	Comportamento
CONFIG_CATEGORIES	Categories	Categories	Catégories	Kategorien	Categorie	분류	类别	類別	Категории	Categorías	Categorías	Categorias
CONFIG_COLUMNS	Columns	Columns	Colonnes	Spalten	Colonne	열	列	欄目	Столбцы	Columnas	Columnas	Colunas
CONFIG_GROUPING	Grouping	Grouping	Groupage	Gruppierungen	Raggruppamento	모아보기	分组	分組	Группировка			Agrupar
CONFIG_PROFILES	Profiles	Profiles	Profils	Profile	Profili	프로필	设定档	設定檔	Профили	Perfiles	Perfiles	Perfis
CONFIG_SKIN_DESATURATE_CATEGORIES	Desaturate Unselected	Desaturate Unselected		Unausgewählte entsättigen		비선택 시 흑백	去饱和未选类别	去飽和未選類別				Descolorir não selecionados
CONFIG_SKIN_CATEGORIES_POSITION_TOP	Top	Top	Haut	Oben		상단	顶	頂				Acima
CONFIG_SKIN_CATEGORIES_POSITION_SIDE	Side	Side	Côté	Seite		옆	边	邊				Do lado
CONFIG_FEATURES_PIN_NEW_ITEMS	Pin New Items	Pin New Items	Epingler les nouveaux objets	Neue Gegenstände anpinnen		새 아이템 강조	置顶新物品	置頂新物品				Fixar novos itens
CONFIG_FEATURES_PIN_RECENTLY_UNEQUIPPED_ITEMS	Pin Recently Unequipped Items	Pin Recently Unequipped Items				최근 착용 해제한 아이템 고정	置顶最近未装备的物品	置頂最近未裝備的物品				
CONFIG_FEATURES_PROTECT_FAVORITES	Prevent Selling Favorite Items	Prevent Selling Favourite Items				즐겨찾기한 아이템 판매 방지	防止出售最爱的物品	防止出售最愛的物品				
CONFIG_APPEARANCE_SCALE	Scale	Scale	Echelle	Skalierung	Scala	크기 비율	缩放	縮放	Масштаб	Escala	Escala	Escala
CONFIG_APPEARANCE_ICON_SIZE	Icon Size	Icon Size	Taille d'icône	Symbolgröße	Dimensione icona	아이콘 크기	图标尺寸	圖示尺寸	Размер значков	Tamaño del icono	Tamaño del icono	Tamanho de Icone
CONFIG_APPEARANCE_ICON_SHAPE	Round Icons	Round Icons	Icônes rondes	Runde Symbole		동그란 아이콘	圆形图标	圓形圖標				
CONFIG_APPEARANCE_ICON_BORDERS	Icon Borders	Icon Borders	Bordures d'icône	Symbolränder	Bordi delle icone	아이콘 테두리	图标外框	圖示外框	Границы значков	Bordes del icono	Bordes del icono	Bordas de Icone
CONFIG_APPEARANCE_ICON_BORDER_THICKNESS	Border Thickness	Border Thickness	Epaisseur des bordures	Rahmenbreite	Spessore del bordo	테두리 두께	外框厚度	外框厚度	Толщина границы	Grosor del borde		Grossura da borda
CONFIG_APPEARANCE_ICON_ZOOM	Mouseover Zoom	Mouseover Zoom				커서 올릴 때 확대	鼠标悬停缩放	滑鼠懸停縮放				
CONFIG_APPEARANCE_PADDING	Padding	Padding	Remplissage	Auffüllen		칸 여백	填充	填充				Preenchimento
CONFIG_APPEARANCE_SPACING	Spacing	Spacing	Espacement	Abstand	Spaziatura	간격	间距	間距	Интервал	Espaciado	Espaciado	Espaçamento
CONFIG_APPEARANCE_BACKDROP	Backdrop Texture	Backdrop Texture	Texture de Fond	Hintergrundtextur	Texture di Sfondo	배경 텍스쳐	背景材质	背景材質	Текстура фона			Textura de fundo
CONFIG_APPEARANCE_BACKDROP_OPACITY	Backdrop Opacity	Backdrop Opacity	Opacité du fond	Hintergrunddeckkraft	Opacità dello sfondo	배경 투명도	背景透明度	背景透明度	Прозрачность	Opacidad del fondo	Opacidad del fondo	Opacidade do Fundo
CONFIG_APPEARANCE_FONT	Font	Font	Police	Schrift	Font	글꼴	字体	字體	Шрифт	Fuente	Fuente	Fonte
CONFIG_APPEARANCE_FONT_SIZE	Size	Size	Taille	Größe	Taglia	크기	尺寸	尺寸	Размер	Tamaño	Tamaño	Tamanho
CONFIG_APPEARANCE_FONT_SIZE_1	Tiny	Tiny	Très petit	Winzig	Minuscola	매우 작음	超小	超小	Крошечный	Minúsculo	Minúsculo	Minúsculo
CONFIG_APPEARANCE_FONT_SIZE_2	Small	Small	Petit	Kleintier	Piccola	작음	小	小	Маленький	Pequeño	Pequeño	Pequeno
CONFIG_APPEARANCE_FONT_SIZE_3	Normal	Normal	Normal	Normal	Normale	기본	普通	普通	Обычный	Normal	Normal	Normal
CONFIG_APPEARANCE_FONT_SIZE_4	Large	Large	Grand	Groß	Grande	큼	大	大	Большой	Grande	Grande	Grande
CONFIG_APPEARANCE_FONT_SIZE_5	Huge	Huge	Très Grand	Riesig	Enorme	매우 큼	超大	超大	Огромный	Gigante	Gigante	Gigante
CONFIG_APPEARANCE_FONT_OUTLINE	Outline	Outline	Contour	Outline	Schema	외곽선	轮廓	描邊	Контур	Contorno	Contorno	Contorno
CONFIG_APPEARANCE_FONT_OUTLINE_1	None	None	Aucun	Nichts	Nessuna	없음	无	無	Нет	Ninguno	Ninguno	Nenhum
CONFIG_APPEARANCE_FONT_OUTLINE_2	Thin	Thin	Mince	Dünn	Sottile	얇음	细	細	Тонкий	Delgado	Delgado	Fino
CONFIG_APPEARANCE_FONT_OUTLINE_3	Thick	Thick	Épais	Dick	Spessa	굵음	粗	粗	Толстый	Gordo	Gordo	Grosso
CONFIG_APPEARANCE_FONT_SHADOW	Shadow	Shadow	Ombre	Schatten		그림자	影	影				Sombra
CONFIG_APPEARANCE_SIDE_PANE_WIDTH	Side Pane Width	Side Pane Width	Largeur du volet latéral	Seitenpanelbreite	Larghezza pannello laterale	측면 칸 넓이	侧窗格宽度	側窗格寬度	Ширина бок. панели	Ancho del panel lateral	Ancho del panel lateral	Largura do painel Lateral
CONFIG_APPEARANCE_ALWAYS_USE_ICONS	Always Use Icons	Always Use Icons	Utiliser toujours les icônes	Immer Symbole benutzen	Usa sempre le icone	항상 아이콘 사용	一直使用图标	永遠使用圖示	Всегда исп. значки	Siempre utilizar iconos	Siempre utilizar iconos	Sempre utilizar ícones
CONFIG_APPEARANCE_SKINNING	Skin	Skin	Apparence	Aussehen		스킨	皮肤	皮膚				
CONFIG_APPEARANCE_SKINNING_DEFAULT	Default	Default	Par défault	Standard		기본	默认	默認				Padrão
CONFIG_APPEARANCE_SKINNING_CLEAN	Clean	Clean		Clean		깔끔함	简约	簡約				Limpa
CONFIG_APPEARANCE_SKINNING_ADDONSKINS	AddOnSkins	AddOnSkins	AddOnSkins	AddOnSkins		AddOnSkins	AddonSkins	AddonSkins				
CONFIG_APPEARANCE_ELVUI_SKIN	ElvUI Skin	ElvUI Skin	Apparence ElvUI	ElvUI Skin	ElvUI Skin	ElvUI 스킨	ElvUI外观	ElvUI外觀	ElvUI Skin			Skin ElvUI
CONFIG_BEHAVIOR_SCROLLING_HEADER	Scrolling	Scrolling	Défilement	Scrollen	Scorrimento	스크롤	滚动	捲動	Прокрутка			Rolamento
CONFIG_BEHAVIOR_SCROLL_WHEEL_SPEED	Wheel Scroll Speed	Wheel Scroll Speed	Vitesse du bouton de défilement	Mausradgeschwindigkeit	Velocità di scorrimento della rotella	스크롤 속도	鼠标滚轮速度	滾輪捲動速度	Скорость прокрутки	Velocidad de la rueda de desplazamiento	Velocidad de la rueda de desplazamiento	Velocidade da roda do mouse
CONFIG_BEHAVIOR_SMOOTH_SCROLLING	Smooth Scrolling	Smooth Scrolling	Défilement léger	Sanftes Scrollen	Scorrimento fluido	부드러운 스크롤	平滑滚动	平滑捲動	Плавная прокрутка	Desplazamiento suave	Desplazamiento suave	Deslizamento suave
CONFIG_BEHAVIOR_SMOOTH_SCROLLING_POWER	Smoothing Strength	Smoothing Strength	Puissance du lissage	Sanftheit-Stärke	Forza levigante	부드러움 강도	平滑强度	平滑強度	Сглаживание	Suavizar fuerza	Suavizar fuerza	Força da suavização
CONFIG_BEHAVIOR_ANIMATIONS	Animations	Animations	Animations	Animationen	Animazioni	애니메이션	动画效果	動畫效果	Анимация	Animaciones	Animaciones	Animações
CONFIG_BEHAVIOR_RESET_WINDOW	Reset Window on Close	Reset Window on Close	Réinitialiser la fênetre à la fermeture	Fenster beim Schließen zurücksetzen	Reimposta finestra alla chiusura	닫으면 창 초기화	关闭后重置视窗	關閉後重設視窗	Сброс при закрытии	Reiniciar ventana al cerrar	Reiniciar ventana al cerrar	Reiniciar Janela ao Fechar
CONFIG_BEHAVIOR_COMBINE_STACKS	Combine Stacks	Combine Stacks	Combiner les Piles	Stapel kombinieren	Combina pile	갯수 합치기	合并堆叠	合併堆疊	Объед. пачки	Combinar montones	Combinar montones	Combinar ítens empilháveis
CONFIG_BEHAVIOR_NEW_ITEMS_HEADER	New Items	New Items	Nouveaux objets	Neue Gegenstände	Nuovi oggetti	새 아이템	新物品	新物品	Новые предметы	Nuevos Objetos		Novo Item
CONFIG_BEHAVIOR_NEW_INDICATORS	Category Indicators	Category Indicators	Indicateur de Catégorie	Kategorieindikatoren	Indicatori di categoria	분류에 표시	类别指标	類別指標	Индикатор категории	Indicadores de Cartegoría		Indicador de Categoria
CONFIG_BEHAVIOR_PIN_NEW	Pin to Top	Pin to Top	Epingler en haut	Anpinnen	Metti in primo piano	상단에 고정	置顶	置頂	Закрепить наверху	Fijar arriba		Manter no Topo
CONFIG_BEHAVIOR_TOOLTIP_HEADER	Tooltips	Tooltips	Infobulle	Tooltips	Tooltips	툴팁	提示资讯	提示資訊	Всплывающие подсказки			Tooltip
CONFIG_BEHAVIOR_EXTENDED_TOOLTIPS	Extended Item Tooltips	Extended Item Tooltips	Info-bulles étendu des articles	Erweiterter Gegenstands Tooltip		아이템 툴팁 확장	详细物品提示	詳細物品提示				Ampliar dicas de itens
CONFIG_BEHAVIOR_TOOLTIP_INFO	Info on Item Tooltips	Info on Item Tooltips	Informations sur les info-bulles des articles	Gegenstands Tooltip	Informazioni sui tooltip degli oggetti	툴팁에 정보 표시	物品提示统计资讯	物品提示統計資訊	Информация на подсказках о предмете	Info en el globo de ayuda		Informação no Tooltip
CONFIG_BEHAVIOR_TOOLTIP_DELAY	Tooltip Delay	Tooltip Delay	Délai d'infobulle	Tooltip-Verzögerung	Ritardo dello tooltip	툴팁 표시 속도	提示延迟	工具提示延遲	Задержка подсказки	Retraso del Globo de Ayuda	Retraso del Globo de Ayuda	Atraso da janela de Dica
CONFIG_BEHAVIOR_TOOLTIP_DELAY_SECOND	Second	Second	Seconde	Sekunden	Secondo	초	秒	秒	Секунда	Segundo	Segundo	Segundo
CONFIG_BEHAVIOR_TOOLTIP_DELAY_SECONDS	Seconds	Seconds	Secondes	Sekunden	Secondi	초	秒	秒	Секунд	Segundos	Segundos	Segundos
CONFIG_BEHAVIOR_ON_OPEN_HEADER	When Opening Bags	When Opening Bags	À l'ouverture des sacs	Wenn Tasche geöffnet wird	Quando si aprono i sacchetti	가방을 열었을 때	打开背包时	打開背包時	При открытии сумки			Quando abrir as bolsas
CONFIG_BEHAVIOR_ON_OPEN_SORTING_HEADER	Sort By	Sort By	Trier par	Sortieren nach	Ordina per	정렬하기	物品排序	物品排序	Сортировать по			Organizar por
CONFIG_BEHAVIOR_ON_OPEN_FILTERING_HEADER	Filter By	Filter By	Filtrer par	Filtern nach	Filtra per	분류하기	类别筛选	類別篩選	Фильтровать по			Filtrar por
CONFIG_BEHAVIOR_ON_OPEN_NONE	None	None	Rien		Nessuna	없음	无	無	Нет			Nenhum
CONFIG_BEHAVIOR_ON_OPEN_USE_PREVIOUS	Restore Previous	Restore Previous	Restaurer précédent	Vorheriges wiederherstellen	Ripristina precedente	이전으로 복구	还原排序	還原排序	Восстановить предыдущие			Restaurar anterior
CONFIG_BEHAVIOR_ON_OPEN_USE_SPECIFIC	Use Specific	Use Specific	Utilisation spécifique	Benutze spezifisches	Usa specifico	특정 분류	特定排序	特定排序	Использовать конкретные			Usar específico
CONFIG_BEHAVIOR_ON_OPEN_KEEP_SEARCH	Restore Search	Restore Search	Restaurer la recherche	Suche wiederherstellen	Ripristina ricerca	검색 복구	还原搜索	還原搜索	Восстановить поиск			Restaurar pesquisa
CONFIG_BEHAVIOR_ON_OPEN_PIN_FAVORITES	Pin Favorites	Pin Favourites	Epingler les Favoris	Favoriten anpinnen	Aggiungi preferiti	즐겨찾기 고정	置顶最爱	置頂最愛	Закрепить избранные			Manter nos favoritos
CONFIG_BEHAVIOR_ON_OPEN_SORT_ASCENDING	Ascending	Ascending	Croissant	Aufsteigend	Ascendente	오름차순	升序	升序	По возрастанию			Ascendente
CONFIG_BEHAVIOR_ON_OPEN_SORT_DESCENDING	Descending	Descending	Décroissant	Absteigend	Discendente	내림차순	降序	降序	По убыванию			descendente
CONFIG_BEHAVIOR_AUTO	Automatically	Automatically	Automatique	Automatisch	Automaticamente	자동으로	自动化	自動化	Автоматически			Automáticamente
CONFIG_BEHAVIOR_AUTO_OPEN	Open	Open	Ouvrir	Öffnen	Aprire	열기	开启	開啟	Открыть			Abrir
CONFIG_BEHAVIOR_AUTO_CLOSE	Close	Close	Fermer	Schließen	chiudere	닫기	关闭	關閉	Закрыть			Fechar
CONFIG_BEHAVIOR_AUTO_MAIL	Mailbox	Mailbox	Boîte aux lettres	Briefkasten	Cassetta postale	우체통	邮箱	郵箱	Почта			Correio
CONFIG_BEHAVIOR_AUTO_AUCTION	Auction House	Auction House	Hôtel des ventes	Auktionshaus	Casa d'aste	경매장	拍卖行	拍賣場	Аукцион			Casa de ações
CONFIG_BEHAVIOR_AUTO_MERCHANT	Merchant	Merchant	Marchand	Händler	Commerciante	상인	商店	商店	Продавец			Mercador
CONFIG_BEHAVIOR_AUTO_BANK	Bank	Bank	Banque	Bank	Banca	은행	银行	銀行	Банк			Banco
CONFIG_CATEGORIES_NAME	Name	Name	Nom	Name	Nome	이름	名称	名稱	Имя	Nombre	Nombre	Nome
CONFIG_CATEGORIES_ICON	Icon	Icon	Icône	Symbol	Icona	아이콘	图标	圖示	Значок	Icono	Icono	Ícone
CONFIG_CATEGORIES_FILTERS	Filters	Filters	Filtres	Filter	Filtri	필터	类别筛选	類別篩選	Фильтр	Filtros	Filtros	Filtros
CONFIG_CATEGORIES_ADD	Add Category	Add Category	Ajouter Catégorie	Kategorie hinzufügen	Aggiungi categoria	분류 추가	新增类别	新增類別	Доб. категорию	Añadir Categoría	Añadir Categoría	Adicionar Categoria
CONFIG_CATEGORIES_DEFAULT_NAME	New Category	New Category	Nouvelle Catégorie	Neue Kategorie	Nuova categoria	새 분류	新类别	新類別	Новая категория	Nueva Categoría	Nueva Categoría	Nova Categoria
CONFIG_CATEGORIES_IMPORT	Import	Import				가져오기	导入	匯入				
CONFIG_CATEGORIES_IMPORT_INSTRUCTION	Paste text...	Paste text...				문자열 붙여넣기...	粘贴文本...	貼上文字...				
CONFIG_CATEGORIES_IMPORT_TIP	Use Ctrl + V to paste the category data	Use Ctrl + V to paste the category data				Ctrl + V를 통해 분류 데이터 붙여넣기	使用 Ctrl + V 粘贴类别数据	使用 Ctrl + V 貼上類別資料				
CONFIG_CATEGORIES_EXPORT	Export	Export				내보내기	导出	匯出				
CONFIG_CATEGORIES_EXPORT_TIP	Use Ctrl + C to copy the category data	Use Ctrl + C to copy the category data				Ctrl + V를 통해 분류 데이터 복사	使用 Ctrl + C 复制类别数据	使用 Ctrl + C 複製類別資料				
CONFIG_CATEGORIES_INCLUDE	Include	Include				포함	包括	包括				
CONFIG_CATEGORIES_EXCLUDE	Exclude	Exclude				제외	排除	排除				
CONFIG_COLUMNS_COLUMN	Column	Column	Colonne	Spalte	Colonna	열	列	欄目	Столбец	Columna	Columna	Coluna
CONFIG_COLUMNS_WIDTH	Width	Width	Largeur	Breite	Larghezza pannello laterale	넓이	宽度	寬度	Ширина	Ancho	Ancho	Largura
CONFIG_COLUMNS_ENABLED	Enabled	Enabled	Activer	Aktiviert	Abilitato	활성화	启用	啟用	Вкл.	Activado	Activado	Habilitado
CONFIG_AUTOMATION	Automation	Automation	Automatiser	Automatisierung		자동화	自动化	自動化				Automação
CONFIG_PROFILES_PROFILE	Settings Profile	Settings Profile	Options du profil	Einstellungsprofil	Profilo delle impostazioni	사용중인 프로필	配置设定档	配置設定檔	Настройки профиля	Perfil de Opciones	Perfil de Opciones	Perfil de Opções
CONFIG_PROFILES_NAME	Name	Name	Nom	Name	Nome	이름	名称	名稱	Имя	Nombre	Nombre	Nome
CONFIG_PROFILES_CHANGE_NAME	Change Name	Change Name	Changer le nom	Name ändern		이름 바꾸기	更换名称	更換名稱				Mudar nome
CONFIG_PROFILES_CHANGE_NAME_INSTRUCTION	Enter name...	Enter name...	Entrer un nom	Name eingeben		이름을 입력하세요...	输入名称	輸入名稱				Digite o nome...
CONFIG_PROFILES_NEW	New	New	Nouveau	Neu	Nuovo	생성	新	新	Новый	Nuevo	Nuevo	Novo
CONFIG_PROFILES_COPY	Copy	Copy	Copier	Kopieren	copia	복사	复制	複製	Копир.	Copiar	Copiar	Copiar
CONFIG_PROFILES_DELETE	Delete	Delete	Supprimer	Löschen	Elimina	삭제	删除	刪除	Удалить	Borrar	Borrar	Apagar
CONFIG_PROFILES_DEFAULT_NAME	New Profile	New Profile	Nouveau Profil	Neues Profil	Nuovo profilo	새 프로필	新设定档	新設定檔	Новый профиль	Nuevo Perfil	Nuevo Perfil	Novo Perfil
CONFIG_PROFILES_DEFAULT_PROFILE	Default Profile	Default Profile		Standard Profil		기본 프로필	默认设定档	默認設定檔				
CONFIG_PROFILES_DEFAULT_PROFILE_UNSET	Ask every time	Ask every time		Jedes mal fragen		매번 묻기	每次都问	每次都問				
CONFIG_PROFILES_DEFAULT_PROFILE_USE_EXISTING	Use this profile:	Use this profile:		Benutze dieses Profil:		해당 프로필 사용:	使用该设定档	使用該設定檔				
CONFIG_PROFILES_CLEAR_DATA	Clear All Data	Clear All Data		Alle Daten löschen		모든 데이터 지우기	清除所有数据	清除所有資料				
CONFIG_PROFILES_CLEAR_DATA_DIALOG	Are you sure you want to clear Sorted's data?\n\nThis will |cffffdd00delete your settings profiles|r and\nSorted will |cffff1133forget all of your characters|r!	Are you sure you want to clear Sorted's data?\n\nThis will |cffffdd00delete your settings profiles|r and\nSorted will |cffff1133forget all of your characters|r!		Bist Du sicher das du die Daten von Sorted löschen willst?\n\nDies wird dein Einstellungsprofil|r  |cffffdd00löschen und \nSorted |cffff1133vergisst alle deine Charaktere|r!		정말로 Sorted의 데이터를 지우시겠습니까?\n\n이 작업은 |cffffdd00모든 프로필을 삭제|r하고\nSorted에 저장된|cffff1133모든 캐릭터 정보를 지웁니다|r!	您确定要清除 Sorted 的数据吗？\n\n这将|cffffdd00删除您的设置档|r 并且\nSorted 将|cffff1133忘记您的所有角色|r！	您確定要清除 Sorted 的資料嗎？\n\n這將|cffffdd00刪除您的設定檔|r 並且\nSorted 將|cffff1133忘記您的所有角色|r！				
PROFILE_SELECTION_HEADER	Select a settings profile for %s	Select a settings profile for %s	Utiliser les pramètres du profil de %s	Wähle ein Einstellungsprofil für %s	Seleziona un profilo di impostazioni per %s	%s의 프로필 세팅 선택	为 %s 选择一个设置的设定档	為 %s 選擇一個設置的設定檔	Выберите профиль настроек для %s			Selecione um perfil de configurações para %s
PROFILE_SELECTION_EXISTING	Existing Profile	Existing Profile		Vorhandenes Profil		기존 프로필	已存的设定档...	已存的設定檔...				
PROFILE_SELECTION_NEW	New Profile	New Profile		Neues Profil		새 프로필	新设定档	新設定檔				
PROFILE_SELECTION_CHOOSE	Choose...	Choose...		Auswählen...		선택하기...	选择	選擇				
PROFILE_SELECTION_SET_DEFAULT	Make this the default for all characters	Make this the default for all characters		Mache dieses Profil zum Standard für alle Charaktere		이 프로필을 모든 캐릭터의 기본 프로필로 설정	把此档设为全部角色的默认设定档	把此檔設為全部角色的默認設定檔				
PROFILE_SELECTION_CHOOSE_EXISTING	Choose existing profile...	Choose existing profile...	Utiliser un profil existant...	Wähle vorhandenes Profil...	Scegli profilo esistente ...	기존 프로필 선택...	选择已存的设定档...	選擇已存的設定檔...	Выбрать существующий профиль...			
PROFILE_SELECTION_CREATE_NEW	Create new profile	Create new profile	Créer un nouveau profil	Erstelle ein neues Profil	Crea nuovo profilo	새 프로필 생성	建立新设定档	建立新設定檔	Создать новый профиль			Criar um novo perfil
PROFILE_SELECTION_CREATE	Create	Create	Créer	Erstellen	Creare	생성	建立	建立	Создать новый профиль			Criar
TOOLTIP_TOGGLE_BLIZZARD	Use Default Bag UI	Use Default Bag UI	Utiliser l'UI de sac par défaut	Benutze Standard UI	Usa l'interfaccia predefinita delle borse	기본 가방 UI 사용	使用预设背包界面	使用預設背包UI	Использовать стандартный вид сумки			Usar interface padrão de bolsas
TOOLTIP_TOGGLE_SORTED	Use Sorted.	Use Sorted.	Utiliser Sorted	Benutze Sorted	Usa Sorted.	Sorted. 사용	使用Sorted	使用Sorted	Использовать Sorted.			Usar Sorted.
TOOLTIP_CLICK_INSTRUCTION_SETTINGS	<Right-click for settings>	<Right-click for settings>				< 우클릭해 설정 >	<右键点击进行设置>	<右鍵點擊進行設定>				
TOOLTIP_SORT_BY	Sort by %s	Sort by %s				%s 기준으로 정렬	按%s排序	按%s排序				
TOOLTIP_LAYOUT_LIST	Display as List	Display as List	Afficher en Liste	Listen-Anzeige	Visualizza come elenco	목록으로 표시	列表显示	列表顯示	Отобразить как список			Mostrar como lista
TOOLTIP_LAYOUT_GRID	Display as Grid	Display as Grid	Afficher en Grille	Grid-Anzeige	Visualizza come griglia	칸으로 표시	格子显示	格子顯示	Отобразить как сетку			Mostrar como grid
TOOLTIP_TITLE_ACCOUNT_GOLD	Account Gold	Account Gold	Or du Compte	Accountweites Gold	Oro dell'Account	계정 골드	账号金额	帳號金錢	Золото акквунта	Oro en la cuenta	Oro en la cuenta	Ouro na conta
TOOLTIP_TITLE_BAGS	Bags	Bags	Sacs	Taschen	Borse	가방	背包	背包	Сумки	Bolsas	Bolsas	Bolsas
TOOLTIP_TITLE_BANK	Bank Bags	Bank Bags	Sacs de banque	Bankfächer	Borse da banca	은행 가방	银行背包	銀行容器	Сумки банка	Bolsas del Banco	Bolsas del Banco	Bolsas do banco
TOOLTIP_TITLE_REAGENTS	Reagent Bank	Reagent Bank	Banque de Composants	Reagenzienbank	Banca reagenti	재료 가방	材料银行	材料銀行	Банк реагентов	Banco de componentes	Banco de componentes	Banco de Materiais
TOOLTIP_NEW_ITEM	1 New Item	1 New Item	1 Nouvel Objet	1 neuer Gegenstand	1 nuovo elemento	1 새 아이템	1个新物品	1個新物品	1 новый предмет	1 Nuevo Objeto		1 Novo Item
TOOLTIP_NEW_ITEMS	%s New Items	%s New Items	% Nouveaux Objets	%s neue Gegenstände	%s nuovi articoli	%s 새 아이템	%s个新物品	%s個新物品	%s новые предметы	%s Nuevos objetos		%s Novos Itens
TOOLTIP_CONFIG	Configure Sorted.	Configure Sorted.	Configurer Sorted.	Sorted. konfigurieren	Configura Ordinati.	Sorted. 설정	设置Sorted。	設置Sorted。	Настройки	Configurar Sorted.	Configurar Sorted.	Configurar Sorted
TOOLTIP_MINIMISE	Hide Side Panel	Hide Side Panel	Cacher le panneau latéral	Seitenpanel verstecken	Nascondi pannello laterale	측면 칸 숨기기	隐藏侧窗格	隱藏側窗格	Скрыть боковую панель	Esconder Panel Lateral	Esconder Panel Lateral	Esconder painel Lateral
TOOLTIP_MAXIMISE	Show Side Panel	Show Side Panel	Afficher le panneau latéral	Seitenpanel anzeigen	Mostra pannello laterale	측면 칸 보이기	显示侧窗格	顯示側窗格	Показать боковую панель	Mostrar Panel Lateral	Mostrar Panel Lateral	Mostrar painel Lateral
TOOLTIP_KEYRING	Keyring	Keyring	Porte-clés	Schlüsselring	Portachiavi	열쇠고리	钥匙圈	鑰匙圈	Брелок	Llavero	Llavero	Chaveiro
TOOLTIP_CONTAINER_BACKPACK	Backpack	Backpack	Sac à dos	Rucksack	Zaino	배낭	背包	背包	Рюкзак	Mochila	Mochila	Mochila
TOOLTIP_CONTAINER_BANK	Bank	Bank	Banque	Bankfächer	Banca	은행	银行	銀行	Банк	Banco de componentes	Banco de componentes	Banco 
TOOLTIP_CONTAINER_REAGENTS	Reagents	Reagents	Composants	Reagenzien	Reagenti	재료 은행	材料银行	材料銀行	Реагенты	Componentes	Componentes	Mercadorias
TOOLTIP_CLEANUP_BAGS	< Click to Clean Up Bags >	< Click to Clean Up Bags >	<Cliquer pour trier les sacs>	Klicken um Tasche aufzuräumen	<Fare clic per pulire i sacchetti>	< 클릭해 가방 정리 >	<点击以整理背包>	< 點擊以整理背包 >	<Щелкните, чтобы очистить сумки>	<Clic para limpiar las bolsas>	<Clic para limpiar las bolsas>	< Clique para limpar as Bolsas >
TOOLTIP_CLEANUP_BANK	< Click to Clean Up Bank >	< Click to Clean Up Bank >	<Cliquer pour trier la Banque>	Klicken um Bank aufzuräumen	<Fare clic per pulire la banca>	< 클릭해 은행 정리 >	<点击以整理银行>	< 點擊以整理銀行 >	<Щелкните, чтобы очистить банк>	<Clic para limpiar el banco>	<Clic para limpiar el banco>	< Clique para limpar o Banco>
TOOLTIP_CLEANUP_REAGENTS	< Click to Clean Up Reagents >	< Click to Clean Up Reagents >	<Cliquer pour trier la Banque de Composants>	Klicken um Reagenzien aufzuräumen	<Fare clic per pulire i reagenti>	< 클릭해 재료 은행 정리 >	<点击以整理材料银行>	< 點擊以整理材料銀行 >	<Щелкните, чтобы очистить банк реагентов>	<Clic para limpiar los componentes>	<Clic para limpiar los componentes>	 < Clique para limpar os Componentes>
TOOLTIP_CLEANUP_ACCOUNT	< Click to Clean Up Warband Bank >	< Click to Clean Up Warband Bank >		Klicken um die Warband Bank aufzuräumen		< 클릭해 전투부대 은행 정리 >	<点击以整理战团银行>	<點擊以整理戰隊銀行>				
TOOLTIP_FORGET_CHARACTER	Forget %s\n\n|cffffffffFree up memory by clearing the data that Sorted \nhas kept on this character.\n\n|cffff0000You will no longer be able to preview their items!	Forget %s\n\n|cffffffffFree up memory by clearing the data that Sorted\n has kept on this character.\n\n|cffff0000You will no longer be able to preview their items!	Oubliez %s\n\n|cffffffff Libérer de la mémoire en effaçant les données que Sorted\nà conservées sur ce caractère.\n|cffff0000Vous ne pourrez plus prévisualiser leurs éléments! 	%s vergesse\n\n|cffffffffErhalte freien Speicher indem die Daten gelöscht werden, die Sorted für diesen Charakter gespeicehrt hat.\n\n|cffff0000Du wirst nicht länger eine Vorschau der Gegenstände dieses Charakters sehen können.	Dimentica %s\n\n|cffffffffLibera memoria cancellando i dati che Ordinati \nha conservato su questo personaggio. \N\n|cffff0000Non sarai più in grado di visualizzare l'anteprima dei loro oggetti!	%s 지우기\n\n|cffffffff이 캐릭터에 대한 Sorted의 데이터를 지워 메모리를 확보합니다.\n\n|cffff0000더 이상 이 캐릭터의 아이템을 확인할 수 없습니다!	遗忘 %s\n\n|cffffffff清除Sorted保留在此\n\n角色的数据来释放内存。\n\n|cffff0000您将不再能够预览他的物品！	遺忘 %s\n\n|cffffffff清除Sorted保留在此\n\n角色的數據來釋放記憶體。\n\n|cffff0000您將不再能夠預覽他們的物品！	Удалить\n\n|cffffffffОсвободите память, очистив данные, которые Sorted сохранил для персонажей.\n\n|cffff0000Вы больше не сможете просмотреть их!	Olvida %s\n\n|cffffffffLibera memoria limpiando los datos que Sorted ha guardado de estos personajes.\n\n|cffff0000Ya no podrás tener la vista previa de sus objetos!	Olvida %s\n\n|cffffffffLibera memoria limpiando los datos que Sorted ha guardado de estos personajes.\n\n|cffff0000Ya no podrás tener la vista previa de sus objetos!	Esquecer %s\n\n|cffffffffLibera memória limpando os dados que Sorted mantém destes personagens.\n\n|cffff0000Você não conseguirá mais ver a prévia destes itens!
TOOLTIP_CONFIG_ALWAYS_USE_ICONS	Always Use Icons:\n|cffffffffHides the default category buttons and forces Sorted \nto use the icons instead, which usually only show when \nthe side pane is minimised.\n\n|cffffee00With this checked, and the side pane maximised, the entire height\nof the window will be used for the category's checkbuttons.\nIn this case, the side pane hides automatically.	Always Use Icons:\n|cffffffffHides the default category buttons and forces Sorted \nto use the icons instead, which usually only show when \nthe side pane is minimised.\n\n|cffffee00With this checked, and the side pane maximised, the entire height\nof the window will be used for the category's checkbuttons.\nIn this case, the side pane hides automatically.	Toujours utiliser les icônes: \n|cffffffffMasque les boutons de catégorie par défaut et force Sorted à n'utiliser que les icônes.\n Ils ne s'affichent généralement que lorsque le volet latéral est réduit.\n|cffffee00Lorsque cette case est cochée et que le volet latéral est agrandi,\ntoute la hauteur de la fenêtre sera utilisée pour les cases à cocher de la catégorie.\nDans ce cas, le volet latéral se masquera automatiquement.	Immer Symbole benutzen:\n|cffffffffVersteckt die Standard-Kategorieknöpfe und zwingt Sorted dazu\nSymbole stattdessen zu verwenden, die normalerweise\n nur angezeigt werden, wenn die Seitenleiste angezeigt wird.\n\n|cffffee00Wenn dies angehakt ist und die Seitenleiste minimiert ist\nwird die gesamte Höhe des Fensters für die Kategorieknöpfe verwendet.\nIn diesem Fall wird die Seitenleiste automatisch versteckt.	Usa sempre icone:\n|cffffffffNasconde i pulsanti delle categorie predefinite e forza Ordinamento \nper utilizzare invece le icone, che di solito vengono visualizzate solo quando \nil riquadro laterale è ridotto a icona. \n\n|cffffee00Con questa opzione selezionata e il riquadro laterale ingrandito, il l'intera altezza \ndella finestra verrà utilizzata per i pulsanti di selezione della categoria. \nIn questo caso, il pannello laterale si nasconde automaticamente.	항상 아이콘 사용하기:\n|cffffffffSorted가 원래의 카테고리 버튼 대신 아이콘을 사용하도록 합니다.\n일반적으론 측면 칸을 접은 경우에만 나타납니다.\n\n|cffffee00이 옵션을 체크하면 세부 분류를 고를 수 있는 공간이 최대화됩니다.\n기존의 대분류 버튼은 자동으로 숨겨집니다.	永远使用图标:\n|cffffffff隐藏预设的类别文字按钮，强制改用图标\n就像是隐藏侧窗格时所显示的样子。\n\n|cffffee00勾选后，显示侧窗格时，整块区域都会用来\n显示类别的复选框，此时侧窗格也会自动隐藏。	永遠使用圖示:\n|cffffffff隱藏預設的類別文字按鈕，強制改用圖示\n就像是隱藏側窗格時所顯示的樣子。\n\n|cffffee00勾選後，顯示側窗格時，整塊區域都會用來\n顯示類別的核取方塊，此時側窗格也會自動隱藏。	Всегда использовать значки:\n|cffffffffСкрывает кнопки категорий по умолчанию и заставляет Sorted использовать вместо них значки, которые обычно отображаются, только когда боковая панель свернута.	Utilizar iconos siempre:\n|cffffffffOculta la categoría de botones por defecto y fuerza a Sorted \na usar a su vez los iconos, que normalmente solo se muestra cuando \nel panel lateral está minimizado.\n\n|cffffee00Activada esta opción,y el panel lateral maximizado, el total de la altura\nde la ventana será usada por la categoría de los botones.\nEn este caso, el panel lateral se oculta automáticamente.	Utilizar iconos siempre:\n|cffffffffOculta la categoría de botones por defecto y fuerza a Sorted \na usar a su vez los iconos, que normalmente solo se muestra cuando \nel panel lateral está minimizado.\n\n|cffffee00Activada esta opción,y el panel lateral maximizado, el total de la altura\nde la ventana será usada por la categoría de los botones.\nEn este caso, el panel lateral se oculta automáticamente.	Sempre usar ícones, esconde as categorias padrões de botões e força o Sorted a usar somente ícones, estes que normalmente aparecem na lateral quando o painel é minimizado. Com esta opção marcada, e o painel maximizado, a altura total da janela será utilizada para os botões de categoria. Neste caso, o painel se esconderá automaticamente.
TOOLTIP_CONFIG_ELVUI_SKIN	ElvUI Skin:\n|cffffffffToggles whether Sorted should use a different\nlook that matches your ElvUI profile.\n\n|cffffee00This feature requires both ElvUI and AddOnSkins to be installed,\nand takes effect only after logging out or performing a /reload.	ElvUI Skin:\n|cffffffffToggles whether Sorted should use a different\nlook that matches your ElvUI profile.\n\n|cffffee00This feature requires both ElvUI and AddOnSkins to be installed,\nand takes effect only after logging out or performing a /reload.	ElvUI Skin:\n|cffffffffPermet de choisir si Sorted doit utiliser un\nlook différent qui correspond à votre profil ElvUI.\n|cffffee00Cette fonctionnalitée nécessite l'installation d'ElvUI et d'AddOnSkins,\net ne prend effet uniquement qu'après la déconnexion ou l'exécution d'un /reload.	ElvUI Skin:\n|cffffffffWenn aktiviert, passt Sorted das Aussehen\nan dein ElvUI Profil an.\n\n|cffffee00Diese Funktion benötigt ElvUI und AddOnSkins installiert,\nund tritt erst nach einem Login oder einem /reload in Kraft.		ElvUI 스킨:\n|cffffffffSorted가 ElvUI와 같은 스킨을 사용할지의 여부를 정합니다.\n\n|cffffee00이 기능은 ElvUI와 AddOnSkins를 모두 설치해야 하며,\n다음에 다시 접속하거나 /reload를 했을 때 적용됩니다.	ElvUI外观:/n|cffffffff切换Sorted是否该使用不同的/n外观以匹配您的ElvUI设定档。 \n\n|cffffee00此功能需要同时安装ElvUI以及AddOnSkins。 \n并且只在登出或是重载后才生效。	ElvUI外觀:/n|cffffffff切換Sorted是否該使用不同的/n外觀以匹配您的ElvUI的設定檔。\n\n|cffffee00此功能需要同時安裝ElvUI以及AddOnSkins。\n並且只在登出或是重載後才生效。	Скин ElvUI:\n|cffffffffПереключает, должен ли Sorted. использовать другой\nвнешний вид, соответствующий вашему профилю ElvUI.\n\n|cffffee00Эта функция требует, чтобы были установлены как ElvUI, так и AddOnSkins,\nи вступает в силу только после выхода из мира или команды /reload.			Skin ElvUI: \n|cffffffffAlterna se Sorted deve usar uma aparência diferente\n que fique parecida com seu perfil do ElvUI. \n\n|cffffee00Este recurso requer que ambos ElvUI e AddOnSkins estejam instalados, \ne entra em vigor somente após um logou ou executar um /reload.
TOOLTIP_CONFIG_SCROLL_WHEEL_SPEED	Wheel Scroll Speed:\n|cffffffffAdjust how far Sorted should scroll\nper each step of the scroll wheel.\n\n|cffffee00(You can hold ALT at any time to scroll quickly)	Wheel Scroll Speed:\n|cffffffffAdjust how far Sorted should scroll\nper each step of the scroll wheel.\n\n|cffffee00(You can hold ALT at any time to scroll quickly)	Vitesse de défilement de la molette:\n|cffffffffAjustez la distance de défilement de Sorted\nà chaque tour de la molette de défilement.\n|cffffee00(Vous pouvez maintenir la touche ALT à tout moment pour faire défiler rapidement)	Mausrad Scrollgeschwindigkeit:\n|cffffffffPasse an, wie weit Sorted beim Drehen des Mausrads scrollen soll.\n\n|cffffee00(Du kannst jederzeit LT drücken um schnell zu scrollen)		스크롤 속도:\n|cffffffff마우스 휠의 한 단계마다 Sorted가 스크롤할 범위를 조정합니다.\n\n|cffffee00(ALT를 누르고 있으면 언제든지 빠르게 스크롤할 수 있습니다)	滚轮滚动速度:\n|cffffffff调整Sorted的滚轮\n每一步应滚动的距离。 \n\n|cffffee00(您可以随时按住ALT快速滚动)	滾輪捲動速度:\n|cffffffff調整Sorted的滾輪\n每一步應滾動的距離。\n\n|cffffee00(您可以隨時按住ALT快速滾動)	Скорость прокрутки колеса:\n|cffffffffУстановите, насколько далеко Sorted должен прокручивать на каждом шаге колеса прокрутки.\n|cffffffff(Вы можете удерживать ALT для быстрой прокрутки).	Velocidad de desplazamiento:\n|cffffffffAjusta hasta dónde Sorted debería desplazarse\npor cada clic de la rueda.\n\n|cffffee00(Puedes presionar ALT en cualquier momento para desplazarte rápidamente)	Velocidad de desplazamiento:\n|cffffffffAjusta hasta dónde Sorted debería desplazarse\npor cada clic de la rueda.\n\n|cffffee00(Puedes presionar ALT en cualquier momento para desplazarte rápidamente)	Velocidade de rolamento do mouse. Ajuste até onde Sorted deve rolar para cada passo de seu rolamento no mouse  (você pode segurar ALT a qualquer momento para rolar rapidamente.)
TOOLTIP_CONFIG_SMOOTH_SCROLLING	Smooth Scrolling:\n|cffffffffToggles whether Sorted should smoothly animate\nwhen scrolling. Raise the smoothing strength to\nincrease the duration of the animation.\n\n|cffffee00(Disable to improve performance)	Smooth Scrolling:\n|cffffffffToggles whether Sorted should smoothly animate\nwhen scrolling. Raise the smoothing strength to\nincrease the duration of the animation.\n\n|cffffee00(Disable to improve performance)	Défilement fluide:\n|cffffffffPermet de définir si Sorted doit s'animer avec douceur\nlors du défilement. Augmentez la force de lissage pour\naugmenter la durée de l'animation.\n|cffffee00(Le désactiver améliore les performances)	Sanftes Scrollen:\n|cffffffffSchaltet um ob Sorted sanft scrollen soll.´\nErhöhe die Stärke um die Dauer der Animation zu erhöhen.\n\ncffffee00(Abschalten um Performance zu verbessern)		부드러운 스크롤:\n|cffffffff스크롤 할 때 Sorted가 부드러운 애니메이션을 가하도록 조정합니다.\n부드러움 강도를 높여서 애니메이션 속도를 늘릴 수 있습니다.\n\n|cffffee00(비활성화하면 성능이 향상됨)	平滑滚动:\n|cffffffff切换Sorted是否有平滑的滚动动画\n滚动时，提高平滑强度\n以增加动画的持续时间。\n\n|cffffee00(停用来提高性能)	平滑捲動:\n|cffffffff切換Sorted是否有平滑的捲動動畫\n滾動時，提高平滑強度\n以增加動畫的持續時間。\n\n|cffffee00(停用來提高性能)	Плавная прокрутка:\n|cffffffffВключает, должна ли Sorted  плавную анимацию при прокрутке.\n|cffffffffУвеличьте сглаживание, чтобы увеличить продолжительность анимации.	Desplazamiento suave:\n|cffffffffAlterna si Sorted debería moverse suavemente\ncuando se desplaza. Sube el rango de suavidad para\nincrementar la duración de la animación.\n\n|cffffee00(Desactivar para mejorar rendimiento)	Desplazamiento suave:\n|cffffffffAlterna si Sorted debería moverse suavemente\ncuando se desplaza. Sube el rango de suavidad para\nincrementar la duración de la animación.\n\n|cffffee00(Desactivar para mejorar rendimiento)	Rolamento Suave. Troca entre rolamento suave ou não na animação do rolamento. Aumente a força do rolamento para aumentar a duração da animação. (Desabilite para melhorar performance)
TOOLTIP_CONFIG_RESET_ON_CLOSE	Reset Window on Close:\n|cffffffffLeave unchecked to have Sorted remember\nyour searching, filtering, and sorting options\nafter closing and reopening the window.	Reset Window on Close:\n|cffffffffLeave unchecked to have Sorted remember\nyour searching, filtering, and sorting options\nafter closing and reopening the window.	Réinitialiser la fenêtre à la fermeture:\n|cffffffffLaisser décoché l'option pour que Sorted se souvienne\nde votre dernière recherche, filtrage et tri\naprès la fermeture et la réouverture de la fenêtre.	Fenster beim Schließen zurücksetzen:\n|cffffffffNicht anhaken, wenn Sorted sich Suchen, Sortierung, Filterung auch nach dem Schließen des Fenster merken soll		닫으면 창 초기화:\n|cffffffffSorted를 닫았다가 다시 열었을 때\n검색, 분류 및 정렬 우선도를 그대로 두려면\n체크하지 마십시오.	关闭后重设视窗:\n|cffffffff取消勾选以让Sorted在\n关闭并重新开启视窗之后记住\n您的搜寻、过滤与排序选项。	關閉後重設視窗:\n|cffffffff取消勾選以讓Sorted在\n關閉並重新開啟視窗之後記住\n您的搜尋、過濾與排序選項。	Сбросить окно при закрытии:\n|cffffffffСнимите флажок, чтобы Sorted запомнил параметры поиска, фильтрации и сортировки после закрытия и повторного открытия окна.	Reinicaiar ventana al cerrar:\n|cffffffffDejar sin marcar para que Sorted recuerde\ntu búsqueda, filtros, y orden de opciones\ndespués de cerrar y reabrir la ventana.	Reinicaiar ventana al cerrar:\n|cffffffffDejar sin marcar para que Sorted recuerde\ntu búsqueda, filtros, y orden de opciones\ndespués de cerrar y reabrir la ventana.	Reiniciar a janela ao fechar: Deixe desmarcado para que Sorted lembre a posição e organização de sua bolsa ao reabrir a janela.
TOOLTIP_CONFIG_COMBINE_STACKS	Combine Stacks:\n|cffffffffMerges identical items into one line.\nInteracting with an item will interact with\nthe largest stack of that item in your bags.	Combine Stacks:\n|cffffffffMerges identical items into one line.\nInteracting with an item will interact with\nthe largest stack of that item in your bags.	Combiner des piles:\n|cffffffffFusionne les articles identiques en une seule ligne.\nL'interaction avec un article prendra toujours la plus grande pile de cet article dans vos sacs.	Stabel kombinieren:\n|cffffffffStapelt identische Gegenstände in einer Reihe. Wenn du mit einem Gegenstand interagierst, beeinflusst du den größten Stapel dieses Gegenständes in deinen Taschen.		갯수 합치기:\n|cffffffff같은 아이템을 한 줄로 합칩니다.\n아이템을 사용하면 해당 아이템 묶음 중\n가장 큰 묶음을 사용합니다.	合并堆叠:\n|cffffffff将相同的物品合并为一行。 \n与物品进行互动将与您背包中\n该物品的最大堆叠物品互动。	合併堆疊:\n|cffffffff將相同的物品合併為一行。\n與物品進行互動將與您背包中\n該物品的最大堆疊物品互動。	Объединить стопки:\n|cffffffffСоединяет идентичные элементы в одну строку.	Combinar Stacks:\n|cffffffffUnifica objetos identicos en una linea.\nçinteractuar con un item hara que se interactue con\nlos items como ese que tienes en tu mochila.	Combinar Stacks:\n|cffffffffUnifica objetos identicos en una linea.\nçinteractuar con un item hara que se interactue con\nlos items como ese que tienes en tu mochila.	Combinar ítens empilháveis: Junta itens idênticos em uma única linha. Interagir com um item irá interagir com a maior pilha de sua bolsa.
TOOLTIP_CONFIG_REMOVE_CATEGORY	Remove "%s"	Remove "%s"	Effacer "%s" ?	%s' entfernen		"%s" 삭제	移除 "%s"	移除 "%s"	Удалить "%s"	Borrar "%s"	Borrar "%s"	Remover "%s
TOOLTIP_BUY_BANK_SLOT	Purchase Bag Slot	Purchase Bag Slot	Acheter un emplacement pour sac	Taschenfach kaufen		가방 칸 구입	购买背包格位	購買背包格位	Купить слот	Comprar Ranura de Bolsa	Comprar Ranura de Bolsa	Comprar Espaço de Bolsa
TOOLTIP_EMPTY_BAG	< Right click to empty this bag >	< Right click to empty this bag >	< Clic droit pour vider ce sac>	< Rechtsklick um diese Tasche zu leeren >		< 우클릭해 가방 비우기 >	<右键点击清空此包>	<右鍵點擊清空此包>				
DIALOG_VOID_STORAGE_DEPOSIT	|cffe2e2ddSorted automatically deposits items directly into your Void Storage\n\n|cffffffffThis action costs %s per item\n\n|cffffee00Are you sure?	|cffe2e2ddSorted automatically deposits items directly into your Void Storage\n\n|cffffffffThis action costs %s per item\n\n|cffffee00Are you sure?				|cffe2e2ddSorted가 자동으로 당신의 아이템을 공허 보관소에 옮깁니다\n\n|cffffffff이를 위해 아이템마다 %s의 비용이 듭니다\n\n|cffffee00확인하셨나요?	|cffe2e2ddSorted 会自动将物品直接存入你的虚空银行\n\n|cffffffff此操作每件物品花费 %s\n\n|cffffee00你确定吗？	|cffe2e2ddSorted 會自動將物品直接存入你的虛空銀行\n\n|cffffffff此操作每件物品花費 %s\n\n|cffffee00你確定嗎？				
DIALOG_DELETE_CHARACTER_DATA	You will no longer be able to preview %s's items until you next play that character	You will no longer be able to preview %s's items until you next play that character	Vous ne pourrez plus prévisualiser les éléments de %s\njusqu'à ce que vous jouiez de nouveau avec ce personnage.	Du wirst nicht länger Gegenstände von %s sehen können bis Du diesen Charakter wieder gespielt hast		해당 캐릭터를 다시 플레이하기 전까지 %s의 아이템을 확인할 수 없을 것입니다.	在您下次玩此角色前，您将无法预览 %s 的物品	在你下次玩此角色前你再也無法預覽 %s的物品	Вы больше не сможете просматривать предметы, пока не сыграете этим персонажем в следующий раз.	No podrás ver la vista previa de los objetos de %s hasta que vuelvas a jugar con ese personaje	No podrás ver la vista previa de los objetos de %s hasta que vuelvas a jugar con ese personaje	Você não poderá mais previsualizar os itens de %s Até você logar nele novamente
DIALOG_DELETE_SETTINGS_PROFILE	Are you sure you want to delete the settings for profile '%s'?	Are you sure you want to delete the settings for profile '%s'?	Voulez-vous vraiment supprimer  la configuration du profil  '%s'  ?	Bist Du sicher, dass du die Einstellungen für Profil '%s' löschen willst?		%s' 프로필 설정을 정말로 삭제하시겠습니까?	您确定要删除设定档'%s'的配置吗？	您確定想要刪除設定檔 '%s'的配置嗎？	Вы действительно хотите удалить настройки для профиля '%s'?	¿Estás seguro que quiéres eliminar las opciones del perfil de '%s'?	¿Estás seguro que quiéres eliminar las opciones del perfil de '%s'?	Tem certeza de que quer elimitar todas as configurações do perfil '%s'?
DIALOG_BUTTON_ACCEPT	Accept	Accept	Accepter	Annehmen		승락	接受	接受	Принять	Aceptar	Aceptar	Aceitar
DIALOG_BUTTON_CANCEL	Cancel	Cancel	Annuler	Abbrechen		취소	取消	取消	Отмена	Cancelar	Cancelar	Cancelar
DIALOG_BUTTON_DELETE	Delete	Delete	Supprimer	Löschen		삭제	删除	刪除	Удалить	Eliminar	Eliminar	Eliminar
WARNING_BANK_NOT_CACHED	Visit a banker once to see your\nbank contents from anywhere	Visit a banker once to see your\nbank contents from anywhere	Rendre visite à un banquier, pour revoir le contenu de votre banque à tout moment depuis le bouton Banque	Besuch einmalig die Bank um deine Bankinhalte hier zu sehen		은행원을 방문하면\n어디서든 은행을 확인할 수 있습니다	访问银行柜员一次以便\n在任何地方查阅您的银行物品	訪問銀行職員一次以在\n任何地方查閱您的銀行物品	Посетите банкира, чтобы увидеть\nсодержимое своего банка\nиз любого места	Visita un banquero para ver los objetos de tu\n banco desde cualquier lugar	Visita un banquero para ver los objetos de tu\n banco desde cualquier lugar	Visite o banqueiro uma vez para ver o conteúdo de seu banco em qualquer lugar
WARNING_BANK_NOT_CACHED_OTHER	Visit a banker once on %s\nto see their bank contents here	Visit a banker once on %s\nto see their bank contents here	Rendez visite à un banquier une fois avec %s\npour voir le contenu de sa banque ici	Besuch einmalig die Bank um die Bankinhalte hier zu sehen		%s의 은행원에게 방문하여\n이곳에서 은행 확인	请在%s访问银行柜员一次\n以便查阅他的银行物品	請在%s訪問銀行職員一次\n以便查閱他的銀行物品	Посетите банкира один раз,\nчтобы увидеть здесь содержимое банка	Visita un banquero para ver los objetos de su\n banco aquí	Visita un banquero para ver los objetos de su\n banco aquí	Visite o banqueiro uma vez para ver o conteúdo de seu banco em qualquer lugar
WARNING_REAGENTBANK_NOT_PURCHASED	Visit a banker to purchase\nthe reagent bank	Visit a banker to purchase\nthe reagent bank	Se rendre à la banque pour acheter la banque de  composants	Besuch einen Bankier um die Reagenzienbank zu kaufen		은행원에게 방문하여\n재료 은행 구입	访问银行柜员来\n购买材料银行	訪問銀行職員來\n購買材料銀行	Посетите банкира\nдля покупки хранилища.	Visita un banquero para comprar\nel banco de componentes	Visita un banquero para comprar\nel banco de componentes	Visite o banqueiro e compre o banco de Reagentes
WARNING_REAGENTBANK_NOT_PURCHASED_OTHER	Visit a banker on %s\nto purchase their reagent bank	Visit a banker on %s\nto purchase their reagent bank	Se rendre à la banque pour acheter la banque de  composants	Besuch einen Bankier um die Reagenzienbank zu kaufen		%s의 은행원에게 방문하여\n재료 은행 구입	请登入%s并访问银行柜员\n来购买他的材料银行	請登入%s並訪問銀行職員\n來購買他們的材料銀行	Посетите банкира, чтобы\nкупить банк реагентов.	Visita un banquero en %s\npara comprar su banco de componentes	Visita un banquero en %s\npara comprar su banco de componentes	Visite o banqueiro com %s\n para comprar o banco de reagentes dele
WARNING_REAGENTBANK_PURCHASE	This tab gives you additional storage for raw profession materials.\nDo you wish to purchase this tab?	This tab gives you additional storage for raw profession materials.\nDo you wish to purchase this tab?	Rendre visite à un banquier avec %s pour acheter sa banque de composants	Dieser Reiter gibt dir zufälligen PLatz für Rohmaterialen für Berufe. Willst Du diesen Reiter kaufen?		이 보관함에는 직업용품을 추가로 보관할 수 있습니다.\n이 보관함을 구입하시겠습니까?	此标签页为您提供了额外的专业原料存储空间。 \n您想要购买此标签页嘛？	此標籤為您提供了額外的存儲專業原料的空間。\n您想要購買此標籤嘛？	Эта вкладка показывает хранилище для материалов профессии.\nВы хотите приобрести эту вкладку?	Esta pestaña te da almacenamiento adicional para materiales de profesiones.\n¿Te gustaría comprar esta pestaña?	Esta pestaña te da almacenamiento adicional para materiales de profesiones.\n¿Te gustaría comprar esta pestaña?	Esta aba lhe dará armazenamento adicional para seus materiais de profissão. Você deseja comprar esta aba?
WARNING_NO_ITEMS_FOUND	No items found	No items found	Aucun objet trouvé	Keine Gegenstände gefunden	Nessun elemento trovato	아이템을 찾을 수 없음	没找到物品	沒找到物品	Пусто	No se encontraron objetos	No se encontraron objetos	Não foram incontrados Itens
WARNING_BAG_COULDNT_EMPTY	Not enough space; bag wasn't completely emptied.	Not enough space; bag wasn't completely emptied.	Pas assez d'espace, le sac n'a pas été complètement vidé.	Nicht ausreichend Platz; die Tasche wurde nicht komplett geleert.		공간이 충분하지 않습니다; 가방이 완전히 비어 있지 않았습니다.	空间不足；包没有完全清空。	空間不足；包沒有完全清空。				Sem espaço; a bolsa não foi esvaziada completamente.]]

    for row in string.gmatch(tsv, "[^\r\n]+") do
        local key = string.match(row, "(.-)\t")
        localizations["enUS"][key], localizations["enGB"][key], localizations["frFR"][key], localizations["deDE"][key],
        localizations["itIT"][key], localizations["koKR"][key], localizations["zhCN"][key], localizations["zhTW"][key],
        localizations["ruRU"][key], localizations["esES"][key], localizations["esMX"][key], localizations["ptBR"][key]
            = string.match(row, ".-\t(.-)\t(.-)\t(.-)\t(.-)\t(.-)\t(.-)\t(.-)\t(.-)\t(.-)\t(.-)\t(.-)\t(.*)")
    end

    for locale, keys in pairs(localizations) do
        for key, s in pairs(keys) do
            localizations[locale][key] = s:gsub("\\n", "\r\n")
        end
    end
end
ParseTSV()

local clientLocale = GetLocale()
local fallback = localesFallback[clientLocale]
if not fallback then fallback = "enUS" end

function S.Localize(key, ...)    
    if ... then
        if localizations[clientLocale][key] and localizations[clientLocale][key] ~= "" then
            return localizations[clientLocale][key]:format(...)
        elseif localizations[fallback][key] and localizations[fallback][key] ~= "" then
            return localizations[fallback][key]:format(...)
        elseif localizations["enUS"][key] then
            return localizations["enUS"][key]:format(...)
        else
            return "["..key.."]"
        end
    else
        if localizations[clientLocale][key] and localizations[clientLocale][key] ~= "" then
            return localizations[clientLocale][key]
        elseif localizations[fallback][key] and localizations[fallback][key] ~= "" then
            return localizations[fallback][key]
        elseif localizations["enUS"][key] then
            return localizations["enUS"][key]
        else
            return "["..key.."]"
        end
    end
end