﻿////////////////////////////////////////////////////////////////////////////////
// Печать

// Процедура печати документа.
//
Процедура Печать(МассивОбъектов, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	ПараметрыВывода.ДоступнаПечатьПоКомплектно = Истина;
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ПересчетТоваров") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
			КоллекцияПечатныхФорм,
			"ПЕРЕСЧЕТТОВАРОВ",  
			"Пересчет Товаров ",
			СформироватьПечатнуюФормуПоНовому(МассивОбъектов, ОбъектыПечати,ПараметрыВывода,"ПЕРЕСЧЕТТОВАРОВ"));//СформироватьПечатнуюФормуЗаказНаПеремещение(МассивОбъектов, ОбъектыПечати,ПараметрыВывода,"ПЕРЕСЧЕТТОВАРОВ"));
		
	КонецЕсли;
	
КонецПроцедуры

// Функция формирует табличный документ с печатной формой заказа,
// разработанной методистами
//
// Возвращаемое значение:
//  Табличный документ - печатная форма накладной
//
Функция СформироватьПечатнуюФормуЗаказНаПеремещение(МассивОбъектов, ОбъектыПечати, ПараметрыПечати, ИД)
	
	Колонка = ФормированиеПечатныхФорм.ИмяДополнительнойКолонки();
	ВыводитьКоды = ЗначениеЗаполнено(Колонка);
	
	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ПересчетТоваров";
	Макет =  ПолучитьМакет("ПФ_MXL_ПересчетТоваров");
	
	ОбластьЗаголовка  = Макет.ПолучитьОбласть("Заголовок");
	ОбластьНазвания1  = Макет.ПолучитьОбласть("ОбщаяТаблица");
	ОбластьШапкиТабл  = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьСтроки     = Макет.ПолучитьОбласть("Строка");
	ОбластьНазвания2  = Макет.ПолучитьОбласть("ОбщаяТаблица1");
	ОбластьНазвания3  = Макет.ПолучитьОбласть("ОбщаяТаблица2");
	ОбластьПодвала    = Макет.ПолучитьОбласть("Подвал");
				
	ЗапросПоШапке = Новый Запрос;
	ЗапросПоШапке.Текст = 
	"ВЫБРАТЬ
	|	ПересчетТоваровТовары.Номенклатура,
	|	ПересчетТоваровТовары.Характеристика,
	|	ПересчетТоваровТовары.КоличествоФакт,
	|	ПересчетТоваровТовары.Количество,
	|	ПересчетТоваровТовары.Ссылка КАК Ссылка,
	|	ПересчетТоваровТовары.КоличествоФакт - ПересчетТоваровТовары.Количество КАК Разница,
	|	ПересчетТоваровТовары.Упаковка
	|ПОМЕСТИТЬ Товары
	|ИЗ
	|	Документ.ПересчетТоваров.Товары КАК ПересчетТоваровТовары
	|ГДЕ
	|	ПересчетТоваровТовары.Ссылка В(&МассивДокументов)
	|	И ПересчетТоваровТовары.Количество - ПересчетТоваровТовары.КоличествоФакт <> 0
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Товары.Номенклатура КАК Номенклатура,
	|	Товары.Характеристика,
	|	Товары.КоличествоФакт,
	|	Товары.Количество,
	|	Товары.Ссылка КАК Ссылка,
	|	Товары.Разница,
	|	ВЫБОР
	|		КОГДА Товары.Разница > 0
	|			ТОГДА Товары.Разница
	|		ИНАЧЕ -Товары.Разница
	|	КОНЕЦ КАК МодульКоличества,
	|	"""" КАК Комментарий,
	|	Товары.Упаковка КАК ЕдИзм
	|ИЗ
	|	Товары КАК Товары
	|ИТОГИ ПО
	|	Ссылка,
	|	Номенклатура";
	
	ЗапросПоШапке.УстановитьПараметр("МассивДокументов", МассивОбъектов);
	
	ДеревоОбъектов = ЗапросПоШапке.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам,"Ссылка");
	ПервыйДокумент = Истина;	
	
	Пока ДеревоОбъектов.Следующий() Цикл
		
		НомерСтрокиНачало = ТабДокумент.ВысотаТаблицы + 1;
		Если Не ПервыйДокумент Тогда
			ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		ПервыйДокумент = Ложь;
		
		ОбластьЗаголовка.Параметры.ПересчетТоваров = ДеревоОбъектов.Ссылка;
		
		ТабДокумент.Вывести(ОбластьЗаголовка);
		ТабДокумент.Вывести(ОбластьНазвания1);
		ТабДокумент.Вывести(ОбластьШапкиТабл);	
		
		ПервыйДокумент = Истина;
		
		ТабОприходования = Новый ТаблицаЗначений;
		ТабОприходования.Колонки.Добавить("Номенклатура");
		ТабОприходования.Колонки.Добавить("Характеристика");
		ТабОприходования.Колонки.Добавить("КоличествоФакт");
		ТабОприходования.Колонки.Добавить("Количество");
		ТабОприходования.Колонки.Добавить("Ссылка");
		ТабОприходования.Колонки.Добавить("Разница");
		ТабОприходования.Колонки.Добавить("МодульКоличества");
		ТабОприходования.Колонки.Добавить("Комментарий");
		
		ТабСписания = Новый ТаблицаЗначений;
		ТабСписания.Колонки.Добавить("Номенклатура");
		ТабСписания.Колонки.Добавить("Характеристика");
		ТабСписания.Колонки.Добавить("КоличествоФакт");
		ТабСписания.Колонки.Добавить("Количество");
		ТабСписания.Колонки.Добавить("Ссылка");
		ТабСписания.Колонки.Добавить("Разница");
		ТабСписания.Колонки.Добавить("МодульКоличества");
		ТабСписания.Колонки.Добавить("Комментарий");
		
		Кол  	= 0;
		КолФакт = 0;
		
		ВыборкаПоНоменклатуре = ДеревоОбъектов.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам,"Номенклатура");
		
		Пока ВыборкаПоНоменклатуре.Следующий() Цикл
			
			ТабСтрок = Новый ТаблицаЗначений;
			ТабСтрок.Колонки.Добавить("Номенклатура");
			ТабСтрок.Колонки.Добавить("Характеристика");
			ТабСтрок.Колонки.Добавить("КоличествоФакт");
			ТабСтрок.Колонки.Добавить("Количество");
			ТабСтрок.Колонки.Добавить("Ссылка");
			ТабСтрок.Колонки.Добавить("Разница");
            ТабСтрок.Колонки.Добавить("МодульКоличества");
		    ТабСтрок.Колонки.Добавить("Комментарий");
			 
			Выборка = ВыборкаПоНоменклатуре.Выбрать();
			Пока Выборка.Следующий() Цикл
				 НовСтр = ТабСтрок.Добавить();
				 ЗаполнитьЗначенияСвойств(НовСтр,Выборка);
			КонецЦикла;
			
			ТабСтрок.Сортировать("МодульКоличества");
			ПолностьюПреобразованно = Ложь;
			Пока Не ПолностьюПреобразованно Цикл
				
				ПолностьюПреобразованно = Истина;
				ПерваяПозиция = Неопределено;
				
				Для каждого Позиция Из ТабСтрок Цикл
					
					Если ПерваяПозиция = Неопределено  Тогда
						ПерваяПозиция = Позиция;
					ИначеЕсли (ПерваяПозиция.Разница/Позиция.Разница) < 0 Тогда
						
						ПолностьюПреобразованно = Ложь;
						Позиция.Разница 		= Позиция.Разница + ПерваяПозиция.Разница;
						Позиция.КоличествоФакт  = Позиция.Количество - Позиция.Разница;
						Позиция.Комментарий     = "Примерный пересорт";
						Если Позиция.Разница > 0 Тогда
							Позиция.МодульКоличества = Позиция.Разница;
							ЗаполнитьЗначенияСвойств(НовСтр,Позиция);
						Иначе 
							Позиция.МодульКоличества = -Позиция.Разница; 
							ЗаполнитьЗначенияСвойств(НовСтр,Позиция);
						КонецЕсли;
						
						ТабСтрок.Удалить(ПерваяПозиция);
						Если Позиция.Разница = 0 Тогда
							ТабСтрок.Удалить(Позиция);
						КонецЕсли; 
						ТабСтрок.Сортировать("МодульКоличества");
						Прервать;
						
					КонецЕсли; 
				КонецЦикла;
				
			КонецЦикла; 
			
			Для каждого Позиция Из ТабСтрок Цикл
				ОбластьСтроки.Параметры.Заполнить(Позиция);
				Если Позиция.Разница <> 0 Тогда
					Кол 	= Кол + Позиция.Количество;
					КолФакт = КолФакт + Позиция.КоличествоФакт;
					ТабДокумент.Вывести(ОбластьСтроки);
					Если  Позиция.Разница > 0  Тогда
						НовСтр = ТабОприходования.Добавить();
						ЗаполнитьЗначенияСвойств(НовСтр,Позиция);
					Иначе 
						НовСтр = ТабСписания.Добавить();
						ЗаполнитьЗначенияСвойств(НовСтр,Позиция);
					КонецЕсли; 
				КонецЕсли; 
				
			КонецЦикла; 
		КонецЦикла;
		ОбластьПодвала.Параметры.Количество 	=  Кол;
		ОбластьПодвала.Параметры.КоличествоФакт =  КолФакт;
		ТабДокумент.Вывести(ОбластьПодвала);

		
		ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		ТабДокумент.Вывести(ОбластьНазвания2);
		ТабДокумент.Вывести(ОбластьШапкиТабл);
		Кол  	= 0;
		КолФакт = 0;
		Для каждого Позиция Из ТабОприходования Цикл
			Кол 	= Кол + Позиция.Количество;
			КолФакт = КолФакт + Позиция.КоличествоФакт;
			ОбластьСтроки.Параметры.Заполнить(Позиция);
			ТабДокумент.Вывести(ОбластьСтроки);
		КонецЦикла;
		ОбластьПодвала.Параметры.Количество 	=  Кол;
		ОбластьПодвала.Параметры.КоличествоФакт =  КолФакт;
		ТабДокумент.Вывести(ОбластьПодвала);
		
		
		ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		ТабДокумент.Вывести(ОбластьНазвания3);
		ТабДокумент.Вывести(ОбластьШапкиТабл);
		Кол  	= 0;
		КолФакт = 0;
		Для каждого Позиция Из ТабСписания Цикл
			Кол 	= Кол + Позиция.Количество;
			КолФакт = КолФакт + Позиция.КоличествоФакт;
			ОбластьСтроки.Параметры.Заполнить(Позиция);
			ТабДокумент.Вывести(ОбластьСтроки);
		КонецЦикла;
		ОбластьПодвала.Параметры.Количество 	=  Кол;
		ОбластьПодвала.Параметры.КоличествоФакт =  КолФакт;
		ТабДокумент.Вывести(ОбластьПодвала);	
		
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабДокумент,НомерСтрокиНачало, ОбъектыПечати, ДеревоОбъектов.Ссылка);
		
	КонецЦикла;
	
	ТабДокумент.АвтоМасштаб = Истина;
	
	Возврат ТабДокумент;
	
КонецФункции

Функция СформироватьПечатнуюФормуПоНовому(МассивОбъектов, ОбъектыПечати, ПараметрыПечати, ИД)
	
	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ПересчетТоваров";
	Макет =  ПолучитьМакет("ПФ_MXL_ПересчетТоваров");
	
	ОбластьЗаголовка      = Макет.ПолучитьОбласть("Заголовок");
	ОбластьНазвания1      = Макет.ПолучитьОбласть("ОбщаяТаблица");
	ОбластьШапкиТабл      = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьСтроки         = Макет.ПолучитьОбласть("Строка");
	ОбластьНазванияОприх  = Макет.ПолучитьОбласть("ОбщаяТаблица1");
	ОбластьНазванияСпис   = Макет.ПолучитьОбласть("ОбщаяТаблица2");
	ОбластьПодвала        = Макет.ПолучитьОбласть("Подвал");
	ОбластьПодвалаОприх   = Макет.ПолучитьОбласть("ПодвалОприходования");
	ОбластьПодвалаСпис    = Макет.ПолучитьОбласть("ПодвалСписания");
	
	ПервыйДокумент = Истина;	
	
	// Знаю что запросы в цикле использовать не айс, но в данном случае количество итераций циклов редко будет больше 1 и для восприятия 
	//    и внесения изменения в будущем данный вариант помоему самый подходящий.
	Для Каждого ЭлемМассива Из МассивОбъектов  Цикл
		
		Запрос = Новый Запрос;
		
		Запрос.УстановитьПараметр("ДокументПересчет", ЭлемМассива);
		Запрос.УстановитьПараметр("ДатаДокумента", ЭлемМассива.Дата);
		Запрос.УстановитьПараметр("ВидЦены", ЭлемМассива.Склад.УчетныйВидЦены);
		
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПересчетТоваровТовары.Номенклатура КАК Номенклатура,
		|	ПересчетТоваровТовары.Характеристика КАК Характеристика,
		|	ПересчетТоваровТовары.Количество КАК Количество,
		|	ПересчетТоваровТовары.КоличествоФакт КАК КоличествоФакт,
		|	ВЫБОР
		|		КОГДА ПересчетТоваровТовары.КоличествоФакт - ПересчетТоваровТовары.Количество > 0
		|			ТОГДА ПересчетТоваровТовары.КоличествоФакт - ПересчетТоваровТовары.Количество
		|		ИНАЧЕ 0
		|	КОНЕЦ КАК Оприходуется,
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследних.Цена, 0) КАК Цена,
		|	ВЫБОР
		|		КОГДА ПересчетТоваровТовары.Количество - ПересчетТоваровТовары.КоличествоФакт > 0
		|			ТОГДА ПересчетТоваровТовары.Количество - ПересчетТоваровТовары.КоличествоФакт
		|		ИНАЧЕ 0
		|	КОНЕЦ * ЕСТЬNULL(ЦеныНоменклатурыСрезПоследних.Цена, 0) КАК СписываетсяСумма,
		|	ВЫБОР
		|		КОГДА ПересчетТоваровТовары.Количество - ПересчетТоваровТовары.КоличествоФакт > 0
		|			ТОГДА ПересчетТоваровТовары.Количество - ПересчетТоваровТовары.КоличествоФакт
		|		ИНАЧЕ 0
		|	КОНЕЦ КАК Списывается,
		|	ПересчетТоваровТовары.НомерСтроки КАК НомерСтроки,
		|	ВЫБОР
		|		КОГДА ПересчетТоваровТовары.КоличествоФакт - ПересчетТоваровТовары.Количество > 0
		|			ТОГДА ПересчетТоваровТовары.КоличествоФакт - ПересчетТоваровТовары.Количество
		|		ИНАЧЕ 0
		|	КОНЕЦ * ЕСТЬNULL(ЦеныНоменклатурыСрезПоследних.Цена, 0) КАК ОприходуетсяСумма
		|ПОМЕСТИТЬ ТаблицаОбщая
		|ИЗ
		|	Документ.ПересчетТоваров.Товары КАК ПересчетТоваровТовары
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних(&ДатаДокумента, ВидЦены = &ВидЦены) КАК ЦеныНоменклатурыСрезПоследних
		|		ПО ПересчетТоваровТовары.Номенклатура = ЦеныНоменклатурыСрезПоследних.Номенклатура
		|			И ПересчетТоваровТовары.Характеристика = ЦеныНоменклатурыСрезПоследних.Характеристика
		|ГДЕ
		|	ПересчетТоваровТовары.Ссылка = &ДокументПересчет
		|	И ПересчетТоваровТовары.Количество - ПересчетТоваровТовары.КоличествоФакт <> 0
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблицаОбщая.Номенклатура КАК Номенклатура,
		|	СУММА(ВЫБОР
		|			КОГДА ТаблицаОбщая.Оприходуется > ТаблицаОбщая.Списывается
		|				ТОГДА ТаблицаОбщая.Оприходуется - ТаблицаОбщая.Списывается
		|			ИНАЧЕ 0
		|		КОНЕЦ) КАК КОприходавнию,
		|	СУММА(ВЫБОР
		|			КОГДА ТаблицаОбщая.Списывается > ТаблицаОбщая.Оприходуется
		|				ТОГДА ТаблицаОбщая.Списывается - ТаблицаОбщая.Оприходуется
		|			ИНАЧЕ 0
		|		КОНЕЦ) КАК КСписанию
		|ПОМЕСТИТЬ ТаблСгрупПоНоменклатуре
		|ИЗ
		|	(ВЫБРАТЬ
		|		ТаблицаОбщая.Номенклатура КАК Номенклатура,
		|		СУММА(ТаблицаОбщая.Оприходуется) КАК Оприходуется,
		|		СУММА(ТаблицаОбщая.Списывается) КАК Списывается
		|	ИЗ
		|		ТаблицаОбщая КАК ТаблицаОбщая
		|	
		|	СГРУППИРОВАТЬ ПО
		|		ТаблицаОбщая.Номенклатура) КАК ТаблицаОбщая
		|
		|СГРУППИРОВАТЬ ПО
		|	ТаблицаОбщая.Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблицаОбщая.НомерСтроки КАК НомерСтроки,
		|	ТаблицаОбщая.Номенклатура КАК Номенклатура,
		|	ТаблицаОбщая.Характеристика КАК Характеристика,
		|	ТаблицаОбщая.Количество КАК Количество,
		|	ТаблицаОбщая.КоличествоФакт КАК КоличествоФакт,
		|	ТаблицаОбщая.Цена КАК Цена,
		|	ТаблицаОбщая.СписываетсяСумма КАК СписываетсяСумма,
		|	ТаблицаОбщая.ОприходуетсяСумма КАК ОприходуетсяСумма,
		|	ТаблицаОбщая.Списывается КАК Списывается,
		|	СУММА(ТаЖеТаблицаОбщая.Списывается) КАК СписываетсяНарастающая,
		|	ТаблицаОбщая.Оприходуется КАК Оприходуется,
		|	СУММА(ТаЖеТаблицаОбщая.Оприходуется) КАК ОприходуетсяНарастающая
		|ПОМЕСТИТЬ ТаблОбщаяСДополнением
		|ИЗ
		|	ТаблицаОбщая КАК ТаблицаОбщая
		|		ЛЕВОЕ СОЕДИНЕНИЕ ТаблицаОбщая КАК ТаЖеТаблицаОбщая
		|		ПО ТаблицаОбщая.НомерСтроки >= ТаЖеТаблицаОбщая.НомерСтроки
		|			И ТаблицаОбщая.Номенклатура = ТаЖеТаблицаОбщая.Номенклатура
		|
		|СГРУППИРОВАТЬ ПО
		|	ТаблицаОбщая.Номенклатура,
		|	ТаблицаОбщая.Характеристика,
		|	ТаблицаОбщая.Количество,
		|	ТаблицаОбщая.КоличествоФакт,
		|	ТаблицаОбщая.Списывается,
		|	ТаблицаОбщая.Оприходуется,
		|	ТаблицаОбщая.Цена,
		|	ТаблицаОбщая.СписываетсяСумма,
		|	ТаблицаОбщая.ОприходуетсяСумма,
		|	ТаблицаОбщая.НомерСтроки
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблОбщаяСДополнением.НомерСтроки КАК НомерСтроки,
		|	ТаблОбщаяСДополнением.Номенклатура КАК Номенклатура,
		|	ТаблОбщаяСДополнением.Характеристика КАК Характеристика,
		|	ТаблОбщаяСДополнением.Количество КАК Количество,
		|	ТаблОбщаяСДополнением.КоличествоФакт КАК КоличествоФакт,
		|	ТаблОбщаяСДополнением.Цена КАК Цена,
		|	ТаблОбщаяСДополнением.СписываетсяСумма КАК СписываетсяСумма,
		|	ТаблОбщаяСДополнением.ОприходуетсяСумма КАК ОприходуетсяСумма,
		|	ТаблОбщаяСДополнением.Оприходуется КАК Оприходуется,
		|	ТаблОбщаяСДополнением.Списывается КАК Списывается
		|ПОМЕСТИТЬ ТаблРасхождений
		|ИЗ
		|	(ВЫБРАТЬ
		|		ТаблОбщаяСДополнением.НомерСтроки КАК НомерСтроки,
		|		ТаблОбщаяСДополнением.Номенклатура КАК Номенклатура,
		|		ТаблОбщаяСДополнением.Характеристика КАК Характеристика,
		|		ТаблОбщаяСДополнением.Количество КАК Количество,
		|		ТаблОбщаяСДополнением.КоличествоФакт КАК КоличествоФакт,
		|		ТаблОбщаяСДополнением.Цена КАК Цена,
		|		ТаблОбщаяСДополнением.СписываетсяСумма КАК СписываетсяСумма,
		|		ТаблОбщаяСДополнением.СписываетсяНарастающая КАК СписываетсяНарастающая,
		|		ТаблОбщаяСДополнением.Списывается КАК Списывается,
		|		ТаблОбщаяСДополнением.Оприходуется КАК Оприходуется,
		|		ТаблОбщаяСДополнением.ОприходуетсяСумма КАК ОприходуетсяСумма
		|	ИЗ
		|		ТаблОбщаяСДополнением КАК ТаблОбщаяСДополнением
		|	ГДЕ
		|		ТаблОбщаяСДополнением.Списывается > 0) КАК ТаблОбщаяСДополнением
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ТаблСгрупПоНоменклатуре КАК ТаблСгрупПоНоменклатуре
		|		ПО ТаблОбщаяСДополнением.Номенклатура = ТаблСгрупПоНоменклатуре.Номенклатура
		|			И ТаблОбщаяСДополнением.СписываетсяНарастающая <= ТаблСгрупПоНоменклатуре.КСписанию
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ТаблОбщаяСДополнением.НомерСтроки,
		|	ТаблОбщаяСДополнением.Номенклатура,
		|	ТаблОбщаяСДополнением.Характеристика,
		|	ТаблОбщаяСДополнением.Количество,
		|	ТаблОбщаяСДополнением.КоличествоФакт,
		|	ТаблОбщаяСДополнением.Цена,
		|	ТаблОбщаяСДополнением.СписываетсяСумма,
		|	ТаблОбщаяСДополнением.ОприходуетсяСумма,
		|	ТаблОбщаяСДополнением.Оприходуется,
		|	ТаблОбщаяСДополнением.Списывается
		|ИЗ
		|	(ВЫБРАТЬ
		|		ТаблОбщаяСДополнением.НомерСтроки КАК НомерСтроки,
		|		ТаблОбщаяСДополнением.Номенклатура КАК Номенклатура,
		|		ТаблОбщаяСДополнением.Характеристика КАК Характеристика,
		|		ТаблОбщаяСДополнением.Количество КАК Количество,
		|		ТаблОбщаяСДополнением.КоличествоФакт КАК КоличествоФакт,
		|		ТаблОбщаяСДополнением.Цена КАК Цена,
		|		ТаблОбщаяСДополнением.ОприходуетсяСумма КАК ОприходуетсяСумма,
		|		ТаблОбщаяСДополнением.Оприходуется КАК Оприходуется,
		|		ТаблОбщаяСДополнением.ОприходуетсяНарастающая КАК ОприходуетсяНарастающая,
		|		ТаблОбщаяСДополнением.СписываетсяСумма КАК СписываетсяСумма,
		|		ТаблОбщаяСДополнением.Списывается КАК Списывается
		|	ИЗ
		|		ТаблОбщаяСДополнением КАК ТаблОбщаяСДополнением
		|	ГДЕ
		|		ТаблОбщаяСДополнением.Оприходуется > 0) КАК ТаблОбщаяСДополнением
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			ТаблСгрупПоНоменклатуре.Номенклатура КАК Номенклатура,
		|			ТаблСгрупПоНоменклатуре.КОприходавнию КАК КОприходавнию
		|		ИЗ
		|			ТаблСгрупПоНоменклатуре КАК ТаблСгрупПоНоменклатуре
		|		ГДЕ
		|			ТаблСгрупПоНоменклатуре.КОприходавнию > 0) КАК ВложенныйЗапрос
		|		ПО ТаблОбщаяСДополнением.Номенклатура = ВложенныйЗапрос.Номенклатура
		|			И ТаблОбщаяСДополнением.ОприходуетсяНарастающая <= ВложенныйЗапрос.КОприходавнию
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблОбщаяСДополнением.НомерСтроки КАК НомерСтроки,
		|	ТаблОбщаяСДополнением.Номенклатура КАК Номенклатура,
		|	ТаблОбщаяСДополнением.Характеристика КАК Характеристика,
		|	ТаблОбщаяСДополнением.Количество КАК Количество,
		|	ТаблОбщаяСДополнением.КоличествоФакт КАК КоличествоФакт,
		|	ТаблОбщаяСДополнением.Цена КАК Цена,
		|	ТаблОбщаяСДополнением.Оприходуется,
		|	ТаблОбщаяСДополнением.ОприходуетсяНарастающая,
		|	ТаблОбщаяСДополнением.ОприходуетсяСумма
		|ПОМЕСТИТЬ ТаблОприходования
		|ИЗ
		|	(ВЫБРАТЬ
		|		ТаблОбщаяСДополнением.НомерСтроки КАК НомерСтроки,
		|		ТаблОбщаяСДополнением.Номенклатура КАК Номенклатура,
		|		ТаблОбщаяСДополнением.Характеристика КАК Характеристика,
		|		ТаблОбщаяСДополнением.Количество КАК Количество,
		|		ТаблОбщаяСДополнением.КоличествоФакт КАК КоличествоФакт,
		|		ТаблОбщаяСДополнением.Цена КАК Цена,
		|		ТаблОбщаяСДополнением.ОприходуетсяСумма КАК ОприходуетсяСумма,
		|		ТаблОбщаяСДополнением.Оприходуется КАК Оприходуется,
		|		ТаблОбщаяСДополнением.ОприходуетсяНарастающая КАК ОприходуетсяНарастающая
		|	ИЗ
		|		ТаблОбщаяСДополнением КАК ТаблОбщаяСДополнением
		|	ГДЕ
		|		ТаблОбщаяСДополнением.Оприходуется > 0) КАК ТаблОбщаяСДополнением
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			ТаблСгрупПоНоменклатуре.Номенклатура КАК Номенклатура,
		|			ТаблСгрупПоНоменклатуре.КОприходавнию КАК КОприходавнию
		|		ИЗ
		|			ТаблСгрупПоНоменклатуре КАК ТаблСгрупПоНоменклатуре
		|		ГДЕ
		|			ТаблСгрупПоНоменклатуре.КОприходавнию > 0) КАК ВложенныйЗапрос
		|		ПО ТаблОбщаяСДополнением.Номенклатура = ВложенныйЗапрос.Номенклатура
		|			И ТаблОбщаяСДополнением.ОприходуетсяНарастающая <= ВложенныйЗапрос.КОприходавнию
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблОбщаяСДополнением.НомерСтроки КАК НомерСтроки,
		|	ТаблОбщаяСДополнением.Номенклатура КАК Номенклатура,
		|	ТаблОбщаяСДополнением.Характеристика КАК Характеристика,
		|	ТаблОбщаяСДополнением.Количество КАК Количество,
		|	ТаблОбщаяСДополнением.КоличествоФакт КАК КоличествоФакт,
		|	ТаблОбщаяСДополнением.Цена КАК Цена,
		|	ТаблОбщаяСДополнением.СписываетсяСумма КАК СписываетсяСумма,
		|	ТаблОбщаяСДополнением.Списывается КАК Списывается,
		|	ТаблОбщаяСДополнением.СписываетсяНарастающая КАК СписываетсяНарастающая
		|ПОМЕСТИТЬ ТаблСписания
		|ИЗ
		|	(ВЫБРАТЬ
		|		ТаблОбщаяСДополнением.НомерСтроки КАК НомерСтроки,
		|		ТаблОбщаяСДополнением.Номенклатура КАК Номенклатура,
		|		ТаблОбщаяСДополнением.Характеристика КАК Характеристика,
		|		ТаблОбщаяСДополнением.Количество КАК Количество,
		|		ТаблОбщаяСДополнением.КоличествоФакт КАК КоличествоФакт,
		|		ТаблОбщаяСДополнением.Цена КАК Цена,
		|		ТаблОбщаяСДополнением.СписываетсяСумма КАК СписываетсяСумма,
		|		ТаблОбщаяСДополнением.Списывается КАК Списывается,
		|		ТаблОбщаяСДополнением.СписываетсяНарастающая КАК СписываетсяНарастающая
		|	ИЗ
		|		ТаблОбщаяСДополнением КАК ТаблОбщаяСДополнением
		|	ГДЕ
		|		ТаблОбщаяСДополнением.Списывается > 0) КАК ТаблОбщаяСДополнением
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			ТаблСгрупПоНоменклатуре.Номенклатура КАК Номенклатура,
		|			ТаблСгрупПоНоменклатуре.КСписанию КАК КСписанию
		|		ИЗ
		|			ТаблСгрупПоНоменклатуре КАК ТаблСгрупПоНоменклатуре
		|		ГДЕ
		|			ТаблСгрупПоНоменклатуре.КСписанию > 0) КАК ВложенныйЗапрос
		|		ПО ТаблОбщаяСДополнением.Номенклатура = ВложенныйЗапрос.Номенклатура
		|			И ТаблОбщаяСДополнением.СписываетсяНарастающая <= ВложенныйЗапрос.КСписанию";
		
		РезультатЗапроса = Запрос.ВыполнитьПакетСПромежуточнымиДанными();
		
		ТаблОбщая = РезультатЗапроса[3].Выгрузить();
		ТаблОприх = РезультатЗапроса[4].Выгрузить();
		ТаблСпис  = РезультатЗапроса[5].Выгрузить();
		
		НомерСтрокиНачало = ТабДокумент.ВысотаТаблицы + 1;
		Если Не ПервыйДокумент Тогда
			ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		ПервыйДокумент = Ложь;

		ОбластьЗаголовка.Параметры.ПересчетТоваров = "Пересчет товаров №"+ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(ЭлемМассива.Номер)+" от "+Формат(ЭлемМассива.Дата, "ДФ=dd.MM.yyyy");
		
    	ТабДокумент.Вывести(ОбластьЗаголовка);
		ТабДокумент.Вывести(ОбластьНазвания1);
		ТабДокумент.Вывести(ОбластьШапкиТабл);	
		
		ТаблОбщая.Сортировать("НомерСтроки");
		Для Каждого СтрТабл Из ТаблОбщая Цикл
			ОбластьСтроки.Параметры.Заполнить(СтрТабл);
			ТабДокумент.Вывести(ОбластьСтроки);
		КонецЦикла;
		ОбластьПодвала.Параметры.Количество     = ТаблОбщая.Итог("Списывается");
		ОбластьПодвала.Параметры.КоличествоФакт = ТаблОбщая.Итог("Оприходуется");
		ОбластьПодвала.Параметры.СуммаСпис      = ТаблОбщая.Итог("СписываетсяСумма");
		ОбластьПодвала.Параметры.СуммаОприх     = ТаблОбщая.Итог("ОприходуетсяСумма");
		ТабДокумент.Вывести(ОбластьПодвала);
		
		
		ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		ОбластьНазванияОприх.Параметры.ПересчетТоваров = "Пересчет товаров №"+ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(ЭлемМассива.Номер)+" от "+Формат(ЭлемМассива.Дата, "ДФ=dd.MM.yyyy");
		ТабДокумент.Вывести(ОбластьНазванияОприх);
		ТабДокумент.Вывести(ОбластьШапкиТабл);
		
		ТаблОприх.Сортировать("НомерСтроки");
		Для Каждого СтрТабл Из ТаблОприх Цикл
			ОбластьСтроки.Параметры.Заполнить(СтрТабл);
			ТабДокумент.Вывести(ОбластьСтроки);
		КонецЦикла;
		ОбластьПодвалаОприх.Параметры.Количество = ТаблОприх.Итог("Оприходуется");
		ОбластьПодвалаОприх.Параметры.Сумма      = ТаблОприх.Итог("ОприходуетсяСумма");
		ТабДокумент.Вывести(ОбластьПодвалаОприх);

		
		ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		ОбластьНазванияСпис.Параметры.ПересчетТоваров = "Пересчет товаров №"+ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(ЭлемМассива.Номер)+" от "+Формат(ЭлемМассива.Дата, "ДФ=dd.MM.yyyy");
		ТабДокумент.Вывести(ОбластьНазванияСпис);
		ТабДокумент.Вывести(ОбластьШапкиТабл);
		
		ТаблСпис.Сортировать("НомерСтроки");
		Для Каждого СтрТабл Из ТаблСпис Цикл
			ОбластьСтроки.Параметры.Заполнить(СтрТабл);
			ТабДокумент.Вывести(ОбластьСтроки);
		КонецЦикла;
		ОбластьПодвалаСпис.Параметры.Количество = ТаблСпис.Итог("Списывается");
		ОбластьПодвалаСпис.Параметры.Сумма      = ТаблСпис.Итог("СписываетсяСумма");
		ТабДокумент.Вывести(ОбластьПодвалаСпис);
		
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабДокумент,НомерСтрокиНачало, ОбъектыПечати, ЭлемМассива);
		
	КонецЦикла;
	
	ТабДокумент.АвтоМасштаб = Истина;
	
	Возврат ТабДокумент;
	
КонецФункции

// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ РЕГИСТРАЦИИ ОБРАБОТКИ

// Формирует структуру с параметрами регистрации регистрации обработки в информационной базе
//
// Параметры:
//	ОбъектыНазначенияФормы - Массив - Массив строк имен объектов метаданных в формате: 
//					<ИмяКлассаОбъектаМетаданного>.[ * | <ИмяОбъектаМетаданных>]. 
//					или строка с именем объекта метаданных 
//	НаименованиеОбработки - строка - Наименование обработки, которым будет заполнено наименование элемента справочника по умолчанию.
//							Необязательно, по умолчанию синоним или представление объекта
//	Информация  - строка - Краткая информация или описание обработки.
//							Необязательно, по умолчанию комментарий объекта
//	Версия - строка - Версия обработки в формате “<старший номер>.<младший номер>” используется при загрузке обработок в информационную базу.
//
//
// Возвращаемое значение:
//		Структура
//
Функция ПолучитьПараметрыРегистрации(ОбъектыНазначенияФормы = Неопределено, НаименованиеОбработки = "", Информация = "", Версия = "1.0")

	Если ТипЗнч(ОбъектыНазначенияФормы) = Тип("Строка") Тогда
		ОбъектНазначенияФормы = ОбъектыНазначенияФормы;
		ОбъектыНазначенияФормы = Новый Массив;
		ОбъектыНазначенияФормы.Добавить(ОбъектНазначенияФормы);
	КонецЕсли; 
	
	ПараметрыРегистрации = Новый Структура;
	ПараметрыРегистрации.Вставить("Вид", "ПечатнаяФорма");
	ПараметрыРегистрации.Вставить("БезопасныйРежим", Ложь);
	ПараметрыРегистрации.Вставить("Назначение", ОбъектыНазначенияФормы);
	
	Если Не ЗначениеЗаполнено(НаименованиеОбработки) Тогда
		НаименованиеОбработки = ЭтотОбъект.Метаданные().Представление();
	КонецЕсли; 
	ПараметрыРегистрации.Вставить("Наименование", НаименованиеОбработки);
	
	Если Не ЗначениеЗаполнено(Информация) Тогда
		Информация = ЭтотОбъект.Метаданные().Комментарий;
	КонецЕсли; 
	ПараметрыРегистрации.Вставить("Информация", Информация);
	
	ПараметрыРегистрации.Вставить("Версия", Версия);

	Возврат ПараметрыРегистрации;

КонецФункции

// Формирует таблицу значений с командами печати
//	
// Возвращаемое значение:
//		ТаблицаЗначений
//
Функция ПолучитьТаблицуКоманд()

	Команды = Новый ТаблицаЗначений;
	
	//Представление команды в пользовательском интерфейсе
	Команды.Колонки.Добавить("Представление", Новый ОписаниеТипов("Строка"));
	
	//Уникальный идентификатор команды или имя макета печати
	Команды.Колонки.Добавить("Идентификатор", Новый ОписаниеТипов("Строка"));
	
	//Способ вызова команды: "ОткрытиеФормы", "ВызовКлиентскогоМетода", "ВызовСерверногоМетода"
	// "ОткрытиеФормы" - применяется только для отчетов и дополнительных отчетов
	// "ВызовКлиентскогоМетода" - вызов процедуры Печать(), определённой в модуле формы обработки
	// "ВызовСерверногоМетода" - вызов процедуры Печать(), определённой в модуле объекта обработки
	Команды.Колонки.Добавить("Использование", Новый ОписаниеТипов("Строка"));
	
	//Показывать оповещение.
	//Если Истина, требуется показать оповещение при начале и при завершении работы обработки. 
	//Имеет смысл только при запуске обработки без открытия формы
	Команды.Колонки.Добавить("ПоказыватьОповещение", Новый ОписаниеТипов("Булево"));
	
	//Дополнительный модификатор команды. 
	//Используется для дополнительных обработок печатных форм на основе табличных макетов.
	//Для таких команд должен содержать строку ПечатьMXL
	Команды.Колонки.Добавить("Модификатор", Новый ОписаниеТипов("Строка"));

	Возврат Команды;

КонецФункции

// Вспомогательная процедура.
//
Процедура ДобавитьКоманду(ТаблицаКоманд, Представление, Идентификатор, Использование = "ВызовСерверногоМетода", ПоказыватьОповещение = Ложь, Модификатор = "ПечатьMXL")

	НоваяКоманда = ТаблицаКоманд.Добавить();
	НоваяКоманда.Представление = Представление;
	НоваяКоманда.Идентификатор = Идентификатор;
	НоваяКоманда.Использование = Использование;
	НоваяКоманда.ПоказыватьОповещение = ПоказыватьОповещение;
	НоваяКоманда.Модификатор = Модификатор;

КонецПроцедуры


// Сервисная экспортная функция. Вызывается в основной программе при регистрации обработки в информационной базе
// Возвращает структуру с параметрами регистрации
//
// Возвращаемое значение:
//		Структура с полями:
//			Вид - строка, вид обработки, один из возможных: "ДополнительнаяОбработка", "ДополнительныйОтчет", 
//					"ЗаполнениеОбъекта", "Отчет", "ПечатнаяФорма", "СозданиеСвязанныхОбъектов"
//			Назначение - Массив строк имен объектов метаданных в формате: 
//					<ИмяКлассаОбъектаМетаданного>.[ * | <ИмяОбъектаМетаданных>]. 
//					Например, "Документ.СчетЗаказ" или "Справочник.*". Параметр имеет смысл только для назначаемых обработок, для глобальных может не задаваться.
//			Наименование - строка - Наименование обработки, которым будет заполнено наименование элемента справочника по умолчанию.
//			Информация  - строка - Краткая информация или описание по обработке.
//			Версия - строка - Версия обработки в формате “<старший номер>.<младший номер>” используется при загрузке обработок в информационную базу.
//			БезопасныйРежим - булево - Принимает значение Истина или Ложь, в зависимости от того, требуется ли устанавливать или отключать безопасный режим 
//							исполнения обработок. Если истина, обработка будет запущена в безопасном режиме. 
//
//
Функция СведенияОВнешнейОбработке() Экспорт
	
	//Инициализируем структуру с параметрами регистрации
	
	//Определяем список объектов, вызывающих обработку
	ОбъектыНазначенияФормы = Новый Массив;
	ОбъектыНазначенияФормы.Добавить("Документ.ПересчетТоваров");
	
	ПараметрыРегистрации = ПолучитьПараметрыРегистрации(ОбъектыНазначенияФормы);
	ПараметрыРегистрации.Версия = "1.0";

	//Определяем команды для печати формы
	
	ТаблицаКоманд = ПолучитьТаблицуКоманд();

	ДобавитьКоманду(ТаблицаКоманд, "Пересчет Товаров ",	"ПересчетТоваров",				);


	ПараметрыРегистрации.Вставить("Команды", ТаблицаКоманд);

	Возврат ПараметрыРегистрации;

КонецФункции
//

//бурум бурум1234234ывацукцук