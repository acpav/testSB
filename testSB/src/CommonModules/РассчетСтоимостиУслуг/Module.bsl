
#Область ПрограммныйИнтерфейс

Процедура ЗаписатьСтоимостьОбработкиХаб(Документ, ИмяФайла, Знач МесяцыОтгрузки) Экспорт 
	
	Календарь = Константы.ОсновнойКалендарь.Получить();
	
	тзДатыВыдач = Новый ТаблицаЗначений;
	тзДатыВыдач.Колонки.Добавить("Период", Новый ОписаниеТипов("Дата"));
	
	ПериодНачало = Неопределено;
	ПериодОкончание = Неопределено;
	Для Каждого Месяц Из МесяцыОтгрузки Цикл
		ПериодНачало = ?(ПериодНачало = Неопределено, Месяц.Ключ, Мин(Месяц.Ключ, ПериодНачало));
		ПериодОкончание = ?(ПериодОкончание = Неопределено, Месяц.Ключ, Макс(Месяц.Ключ, ПериодОкончание));
		стрТЗ = тзДатыВыдач.Добавить();
		стрТЗ.Период = Месяц.Ключ;
	КонецЦикла;

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	тзДатыВыдач.Период КАК Период
	|ПОМЕСТИТЬ втПериоды
	|ИЗ
	|	&тзДатыВыдач КАК тзДатыВыдач
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	МАКСИМУМ(ТарифыОбработкиХабов.Период) КАК Период,
	|	втПериоды.Период КАК ПериодОтгрузки
	|ПОМЕСТИТЬ втДатыТарифовХабов
	|ИЗ
	|	РегистрСведений.ТарифыОбработкиХабов КАК ТарифыОбработкиХабов
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ втПериоды КАК втПериоды
	|		ПО ТарифыОбработкиХабов.Период <= втПериоды.Период
	|
	|СГРУППИРОВАТЬ ПО
	|	втПериоды.Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втДатыТарифовХабов.ПериодОтгрузки КАК Период,
	|	ТарифыОбработкиХабов.СреднедневноеКоличествоГрузовыхМест КАК СреднедневноеКоличествоГрузовыхМест,
	|	ТарифыОбработкиХабов.Стоимость КАК Стоимость
	|ИЗ
	|	втДатыТарифовХабов КАК втДатыТарифовХабов
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ТарифыОбработкиХабов КАК ТарифыОбработкиХабов
	|		ПО втДатыТарифовХабов.Период = ТарифыОбработкиХабов.Период
	|
	|УПОРЯДОЧИТЬ ПО
	|	СреднедневноеКоличествоГрузовыхМест
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КОЛИЧЕСТВО(*) КАК Колво,
	|	НАЧАЛОПЕРИОДА(СтоимостьУслугСортировки.Период, МЕСЯЦ) КАК Период
	|ИЗ
	|	РегистрНакопления.СтоимостьУслугСортировки КАК СтоимостьУслугСортировки
	|ГДЕ
	|	СтоимостьУслугСортировки.Период МЕЖДУ &ПериодНачало И &ПериодОкончание
	|	И СтоимостьУслугСортировки.ТипГрузовогоМеста = &ТипГрузовогоМеста
	|	И СтоимостьУслугСортировки.УслугаСортировки = &УслугаСортировки
	|
	|СГРУППИРОВАТЬ ПО
	|	НАЧАЛОПЕРИОДА(СтоимостьУслугСортировки.Период, МЕСЯЦ)
	|
	|ИМЕЮЩИЕ
	|	КОЛИЧЕСТВО(*) > 0
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КалендарныеГрафики.ДатаГрафика КАК Период
	|ИЗ
	|	РегистрСведений.КалендарныеГрафики КАК КалендарныеГрафики
	|ГДЕ
	|	КалендарныеГрафики.Календарь = &Календарь
	|	И НЕ КалендарныеГрафики.ДеньВключенВГрафик
	|	И КалендарныеГрафики.ДатаГрафика МЕЖДУ &ПериодНачало И &ПериодОкончание";
	
	Запрос.УстановитьПараметр("Календарь", Календарь);
	Запрос.УстановитьПараметр("ПериодНачало", ПериодНачало);
	Запрос.УстановитьПараметр("ПериодОкончание", КонецМесяца(ПериодОкончание));
	Запрос.УстановитьПараметр("УслугаСортировки", Перечисления.УслугаСортировки.Обработка);
	Запрос.УстановитьПараметр("ТипГрузовогоМеста", "Хаб");
	Запрос.УстановитьПараметр("тзДатыВыдач", тзДатыВыдач);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	тзКоличествоГМ = РезультатЗапроса[3].Выгрузить();
	
	тзСтоимостьУслугОбработкиХаб = РезультатЗапроса[2].Выгрузить();
	тзСтоимостьУслугОбработкиХаб.Индексы.Добавить("Период");
	
	ВыходныеИПраздничныеДни = Новый Соответствие;
	ВыборкаВыходныеИПраздничныеДни = РезультатЗапроса[4].Выбрать();
	Пока ВыборкаВыходныеИПраздничныеДни.Следующий() Цикл
		ВыходныеИПраздничныеДни.Вставить(ВыборкаВыходныеИПраздничныеДни.Период, Истина);
	КонецЦикла;
	
	Чтение = Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.UTF8);
	
	Чтение.ПрочитатьСтроку();
	
	Строка = Чтение.ПрочитатьСтроку();
	
	регСтоимостьУслугСортировки = РегистрыНакопления.СтоимостьУслугСортировки.СоздатьНаборЗаписей();
	регСтоимостьУслугСортировки.Отбор.Регистратор.Установить(Документ);
	
	ЗаписейВОднойПорции = 9000;
	
	Пока Строка <> Неопределено Цикл
		
		Попытка
			Поля = ПрочитатьПоля(Строка);
		Исключение
			Чтение.Закрыть();
			Документы.ЗагрузкаДанных.ЗаписатьСтатусДокумента(Документ, Перечисления.СтатусЗагрузкиДанных.ОшибкаРассчета, ОписаниеОшибки());
			Возврат;
		КонецПопытки;
		
		Если Поля.КодТипаОбработки <> "Хаб" Тогда
			
			Строка = Чтение.ПрочитатьСтроку();
			
			Продолжить;
			
		КонецЕсли;
		
		СтоимостьСортировки = 0;
		
		ДатаУбытия = Дата(СтрЗаменить(Поля.Дата_Убытие, "-", "") + СтрЗаменить(Поля.Время_Убытие, ":", ""));
		
		КолвоГМ = тзКоличествоГМ.Найти(НачалоМесяца(ДатаУбытия), "Период");
		Если КолвоГМ = Неопределено Тогда
			КолвоГМ = МесяцыОтгрузки[НачалоМесяца(ДатаУбытия)];
		Иначе
			КолвоГМ = КолвоГМ.Колво + МесяцыОтгрузки[НачалоМесяца(ДатаУбытия)];
		КонецЕсли;
		НайденныеСтроки = тзСтоимостьУслугОбработкиХаб.НайтиСтроки(Новый Структура("Период", НачалоМесяца(ДатаУбытия)));
		Для Каждого эл Из НайденныеСтроки Цикл
			СтоимостьСортировки = эл.Стоимость;
			Если (КолвоГМ / День(КонецМесяца(ДатаУбытия))) < эл.СреднедневноеКоличествоГрузовыхМест Тогда
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если СтоимостьСортировки > 0 Тогда
			
			СтоимостьСортировки = СтоимостьСортировки * ?(ВыходныеИПраздничныеДни[НачалоДня(ДатаУбытия)] = Неопределено, 1, 2);
			
			Движение = регСтоимостьУслугСортировки.Добавить();
			Движение.Регистратор = Документ;
			Движение.Период = ДатаУбытия;
			Движение.Стоимость = СтоимостьСортировки;
			Движение.ТипГрузовогоМеста = Поля.КодТипаОбработки;
			Движение.УслугаСортировки = Перечисления.УслугаСортировки.Обработка;
			Движение.НомерГрузовогоМеста = Поля.НомерГрузовогоМеста;
			Движение.ЗаказКлиента = Поля.ЗаказКлиента;
			
			Если регСтоимостьУслугСортировки.Количество() > ЗаписейВОднойПорции Тогда
				Если Документы.ЗагрузкаДанных.ПрочитатьСтатусДокумента(Документ) = Перечисления.СтатусЗагрузкиДанных.ИдетРассчет Тогда				
					Попытка
						регСтоимостьУслугСортировки.Записать(Ложь);
					Исключение
						Чтение.Закрыть();
						Документы.ЗагрузкаДанных.ЗаписатьСтатусДокумента(Документ, Перечисления.СтатусЗагрузкиДанных.ОшибкаРассчета, ОписаниеОшибки());
						Возврат;
					КонецПопытки;
				Иначе
					Чтение.Закрыть();
					Возврат;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		Строка = Чтение.ПрочитатьСтроку();
		
	КонецЦикла;
	
	Чтение.Закрыть();
	
	Если регСтоимостьУслугСортировки.Количество() > 0 Тогда
		Если Документы.ЗагрузкаДанных.ПрочитатьСтатусДокумента(Документ) = Перечисления.СтатусЗагрузкиДанных.ИдетРассчет Тогда				
			Попытка
				регСтоимостьУслугСортировки.Записать(Ложь);
			Исключение
				Документы.ЗагрузкаДанных.ЗаписатьСтатусДокумента(Документ, Перечисления.СтатусЗагрузкиДанных.ОшибкаРассчета, ОписаниеОшибки());
			КонецПопытки;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаписатьСтоимостьОбработки(Документ, ИмяФайла, Знач МесяцыОтгрузки) Экспорт
	
	Календарь = Константы.ОсновнойКалендарь.Получить();
	
	тзДатыВыдач = Новый ТаблицаЗначений;
	тзДатыВыдач.Колонки.Добавить("Период", Новый ОписаниеТипов("Дата"));
	
	ПериодНачало = Неопределено;
	ПериодОкончание = Неопределено;
	Для Каждого Месяц Из МесяцыОтгрузки Цикл
		ПериодНачало = ?(ПериодНачало = Неопределено, Месяц.Ключ, Мин(Месяц.Ключ, ПериодНачало));
		ПериодОкончание = ?(ПериодОкончание = Неопределено, Месяц.Ключ, Макс(Месяц.Ключ, ПериодОкончание));
		стрТЗ = тзДатыВыдач.Добавить();
		стрТЗ.Период = Месяц.Ключ;
	КонецЦикла;

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	тзДатыВыдач.Период КАК Период
	|ПОМЕСТИТЬ втПериоды
	|ИЗ
	|	&тзДатыВыдач КАК тзДатыВыдач
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	МАКСИМУМ(ТарифыУслугСортировки.Период) КАК Период,
	|	ТарифыУслугСортировки.ТипГрузовогоМеста КАК ТипГрузовогоМеста,
	|	втПериоды.Период КАК ПериодОтгрузки
	|ПОМЕСТИТЬ втДатыТарифов
	|ИЗ
	|	РегистрСведений.ТарифыУслугСортировки КАК ТарифыУслугСортировки
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ втПериоды КАК втПериоды
	|		ПО ТарифыУслугСортировки.Период <= втПериоды.Период
	|ГДЕ
	|	ТарифыУслугСортировки.УслугаСортировки = &УслугаСортировки
	|
	|СГРУППИРОВАТЬ ПО
	|	ТарифыУслугСортировки.ТипГрузовогоМеста,
	|	втПериоды.Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втДатыТарифов.ПериодОтгрузки КАК Период,
	|	ТарифыУслугСортировки.Стоимость КАК Стоимость,
	|	ТарифыУслугСортировки.ТипГрузовогоМеста КАК ТипГрузовогоМеста
	|ИЗ
	|	втДатыТарифов КАК втДатыТарифов
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ТарифыУслугСортировки КАК ТарифыУслугСортировки
	|		ПО втДатыТарифов.ТипГрузовогоМеста = ТарифыУслугСортировки.ТипГрузовогоМеста
	|			И втДатыТарифов.Период = ТарифыУслугСортировки.Период
	|ГДЕ
	|	ТарифыУслугСортировки.УслугаСортировки = &УслугаСортировки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КалендарныеГрафики.ДатаГрафика КАК Период
	|ИЗ
	|	РегистрСведений.КалендарныеГрафики КАК КалендарныеГрафики
	|ГДЕ
	|	КалендарныеГрафики.Календарь = &Календарь
	|	И НЕ КалендарныеГрафики.ДеньВключенВГрафик
	|	И КалендарныеГрафики.ДатаГрафика МЕЖДУ &ПериодНачало И &ПериодОкончание";
	
	Запрос.УстановитьПараметр("Календарь", Календарь);
	Запрос.УстановитьПараметр("ПериодНачало", ПериодНачало);
	Запрос.УстановитьПараметр("ПериодОкончание", КонецМесяца(ПериодОкончание));
	Запрос.УстановитьПараметр("УслугаСортировки", Перечисления.УслугаСортировки.Обработка);
	Запрос.УстановитьПараметр("тзДатыВыдач", тзДатыВыдач);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	тзСтоимостьУслугОбработки = РезультатЗапроса[2].Выгрузить();
	тзСтоимостьУслугОбработки.Индексы.Добавить("Период");
	тзСтоимостьУслугОбработки.Индексы.Добавить("ТипГрузовогоМеста");
	
	ВыходныеИПраздничныеДни = Новый Соответствие;
	ВыборкаВыходныеИПраздничныеДни = РезультатЗапроса[3].Выбрать();
	Пока ВыборкаВыходныеИПраздничныеДни.Следующий() Цикл
		ВыходныеИПраздничныеДни.Вставить(ВыборкаВыходныеИПраздничныеДни.Период, Истина);
	КонецЦикла;
	
	Чтение = Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.UTF8);
	
	Чтение.ПрочитатьСтроку();
	
	Строка = Чтение.ПрочитатьСтроку();
	
	регСтоимостьУслугСортировки = РегистрыНакопления.СтоимостьУслугСортировки.СоздатьНаборЗаписей();
	регСтоимостьУслугСортировки.Отбор.Регистратор.Установить(Документ);
	
	ЗаписейВОднойПорции = 9000;
	
	Пока Строка <> Неопределено Цикл
		
		Попытка
			Поля = ПрочитатьПоля(Строка);
		Исключение
			Чтение.Закрыть();
			Документы.ЗагрузкаДанных.ЗаписатьСтатусДокумента(Документ, Перечисления.СтатусЗагрузкиДанных.ОшибкаРассчета, ОписаниеОшибки());
			Возврат;
		КонецПопытки;
		
		Если Поля.КодТипаОбработки = "Хаб" Тогда
			Строка = Чтение.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;
		
		ДатаУбытия = Дата(СтрЗаменить(Поля.Дата_Убытие, "-", "") + СтрЗаменить(Поля.Время_Убытие, ":", ""));
		
		СтоимостьСортировки = 0;
		
		НайденныеСтроки = тзСтоимостьУслугОбработки.НайтиСтроки(Новый Структура("Период, ТипГрузовогоМеста", НачалоМесяца(ДатаУбытия), Поля.КодТипаОбработки));
		Если НайденныеСтроки.Количество() > 0 Тогда
			СтоимостьСортировки = НайденныеСтроки[0].Стоимость;
		КонецЕсли;
		
		Если СтоимостьСортировки > 0 Тогда
			
			СтоимостьСортировки =
			СтоимостьСортировки * ?(ВыходныеИПраздничныеДни[НачалоДня(ДатаУбытия)] = Неопределено, 1, 2);
			
			Движение = регСтоимостьУслугСортировки.Добавить();
			Движение.Регистратор = Документ;
			Движение.Период = ДатаУбытия;
			Движение.Стоимость = СтоимостьСортировки;
			Движение.ТипГрузовогоМеста = Поля.КодТипаОбработки;
			Движение.УслугаСортировки = Перечисления.УслугаСортировки.Обработка;
			Движение.НомерГрузовогоМеста = Поля.НомерГрузовогоМеста;
			Движение.ЗаказКлиента = Поля.ЗаказКлиента;
			
			Если регСтоимостьУслугСортировки.Количество() > ЗаписейВОднойПорции Тогда
				
				Если Документы.ЗагрузкаДанных.ПрочитатьСтатусДокумента(Документ) = Перечисления.СтатусЗагрузкиДанных.ИдетРассчет Тогда				
					Попытка
						регСтоимостьУслугСортировки.Записать(Ложь);
					Исключение
						Чтение.Закрыть();
						Документы.ЗагрузкаДанных.ЗаписатьСтатусДокумента(Документ, Перечисления.СтатусЗагрузкиДанных.ОшибкаРассчета, ОписаниеОшибки());
						Возврат;
					КонецПопытки;
				Иначе
					Чтение.Закрыть();
					Возврат;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		Строка = Чтение.ПрочитатьСтроку();
		
	КонецЦикла;
	
	Чтение.Закрыть();
	
	Если регСтоимостьУслугСортировки.Количество() > 0 Тогда
		Если Документы.ЗагрузкаДанных.ПрочитатьСтатусДокумента(Документ) = Перечисления.СтатусЗагрузкиДанных.ИдетРассчет Тогда				
			Попытка
				регСтоимостьУслугСортировки.Записать(Ложь);
			Исключение
				Документы.ЗагрузкаДанных.ЗаписатьСтатусДокумента(Документ, Перечисления.СтатусЗагрузкиДанных.ОшибкаРассчета, ОписаниеОшибки());
			КонецПопытки;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаписатьСтоимостьХранения(Документ, ИмяФайла, Знач МесяцыОтгрузки, Знач ТаблицаДиапазонов) Экспорт
	
	ТаблицаДиапазонов = ЗаполнитьДниХранения(ТаблицаДиапазонов);
	
	Календарь = Константы.ОсновнойКалендарь.Получить();
	
	тзДатыВыдач = Новый ТаблицаЗначений;
	тзДатыВыдач.Колонки.Добавить("Период", Новый ОписаниеТипов("Дата"));
	
	ПериодНачало = Неопределено;
	ПериодОкончание = Неопределено;
	Для Каждого Месяц Из МесяцыОтгрузки Цикл
		ПериодНачало = ?(ПериодНачало = Неопределено, Месяц.Ключ, Мин(Месяц.Ключ, ПериодНачало));
		ПериодОкончание = ?(ПериодОкончание = Неопределено, Месяц.Ключ, Макс(Месяц.Ключ, ПериодОкончание));
		стрТЗ = тзДатыВыдач.Добавить();
		стрТЗ.Период = Месяц.Ключ;
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	тзДатыВыдач.Период КАК Период
	|ПОМЕСТИТЬ втПериоды
	|ИЗ
	|	&тзДатыВыдач КАК тзДатыВыдач
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	МАКСИМУМ(ТарифыУслугСортировки.Период) КАК Период,
	|	ТарифыУслугСортировки.ТипГрузовогоМеста КАК ТипГрузовогоМеста,
	|	втПериоды.Период КАК ПериодОтгрузки
	|ПОМЕСТИТЬ втДатыТарифов
	|ИЗ
	|	РегистрСведений.ТарифыУслугСортировки КАК ТарифыУслугСортировки
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ втПериоды КАК втПериоды
	|		ПО ТарифыУслугСортировки.Период <= втПериоды.Период
	|ГДЕ
	|	ТарифыУслугСортировки.УслугаСортировки = &УслугаСортировки
	|
	|СГРУППИРОВАТЬ ПО
	|	ТарифыУслугСортировки.ТипГрузовогоМеста,
	|	втПериоды.Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втДатыТарифов.ПериодОтгрузки КАК Период,
	|	ТарифыУслугСортировки.Стоимость КАК Стоимость,
	|	ТарифыУслугСортировки.ТипГрузовогоМеста КАК ТипГрузовогоМеста
	|ИЗ
	|	втДатыТарифов КАК втДатыТарифов
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ТарифыУслугСортировки КАК ТарифыУслугСортировки
	|		ПО втДатыТарифов.ТипГрузовогоМеста = ТарифыУслугСортировки.ТипГрузовогоМеста
	|			И втДатыТарифов.Период = ТарифыУслугСортировки.Период
	|ГДЕ
	|	ТарифыУслугСортировки.УслугаСортировки = &УслугаСортировки";
	
	Запрос.УстановитьПараметр("Календарь", Календарь);
	Запрос.УстановитьПараметр("ПериодНачало", ПериодНачало);
	Запрос.УстановитьПараметр("ПериодОкончание", КонецМесяца(ПериодОкончание));
	Запрос.УстановитьПараметр("УслугаСортировки", Перечисления.УслугаСортировки.Хранение);
	Запрос.УстановитьПараметр("тзДатыВыдач", тзДатыВыдач);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	тзТарифыХранения = РезультатЗапроса.Выгрузить();
	
	Чтение = Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.UTF8);
	
	Чтение.ПрочитатьСтроку();
	
	Строка = Чтение.ПрочитатьСтроку();
	
	регСтоимостьУслугСортировки = РегистрыНакопления.СтоимостьУслугСортировки.СоздатьНаборЗаписей();
	регСтоимостьУслугСортировки.Отбор.Регистратор.Установить(Документ);
	
	ЗаписейВОднойПорции = 9000;
	
	Пока Строка <> Неопределено Цикл
		
		Попытка
			Поля = ПрочитатьПоля(Строка);
		Исключение
			Чтение.Закрыть();
			Документы.ЗагрузкаДанных.ЗаписатьСтатусДокумента(Документ, Перечисления.СтатусЗагрузкиДанных.ОшибкаРассчета, ОписаниеОшибки());
			Возврат;
		КонецПопытки;
		
		СтоимостьХранения = 0;
		
		ДатаУбытия = Дата(СтрЗаменить(Поля.Дата_Убытие, "-", "") + СтрЗаменить(Поля.Время_Убытие, ":", ""));
		ДатаПрибытия = Дата(СтрЗаменить(Поля.Дата_Прибытие, "-", "") + СтрЗаменить(Поля.Время_Прибытие, ":", ""));
		
		Если ДатаУбытия - ДатаПрибытия > 24 * 60 * 60 Тогда
			
			ТарифХранения = 0;
			ТарифыХранения = тзТарифыХранения.НайтиСтроки(Новый Структура("Период, ТипГрузовогоМеста", НачалоМесяца(ДатаУбытия), Поля.КодТипаОбработки));
			Если ТарифыХранения.Количество() > 0 Тогда
				ТарифХранения = ТарифыХранения[0].Стоимость;
			КонецЕсли;
			
			ДнейХранения = 0;
			ДниХранения = ТаблицаДиапазонов.НайтиСтроки(Новый Структура("ДатаПрибытия, ДатаУбытия", НачалоДня(ДатаПрибытия), НачалоДня(ДатаУбытия)));
			Если ДниХранения.Количество() > 0 Тогда
				ДнейХранения = ДниХранения[0].ДнейХранения;
			КонецЕсли;
			
			СтоимостьХранения = ТарифХранения * ДнейХранения;
			
		КонецЕсли;
				
		Если СтоимостьХранения > 0 Тогда
			Движение = регСтоимостьУслугСортировки.Добавить();
			Движение.Регистратор = Документ;
			Движение.Период = ДатаУбытия;
			Движение.Стоимость = СтоимостьХранения;
			Движение.ТипГрузовогоМеста = Поля.КодТипаОбработки;
			Движение.УслугаСортировки = Перечисления.УслугаСортировки.Хранение;
			Движение.НомерГрузовогоМеста = Поля.НомерГрузовогоМеста;
			Движение.ЗаказКлиента = Поля.ЗаказКлиента;
			
			Если регСтоимостьУслугСортировки.Количество() > ЗаписейВОднойПорции Тогда
				Если Документы.ЗагрузкаДанных.ПрочитатьСтатусДокумента(Документ) = Перечисления.СтатусЗагрузкиДанных.ИдетРассчет Тогда				
					Попытка
						регСтоимостьУслугСортировки.Записать(Ложь);
					Исключение
						Чтение.Закрыть();
						Документы.ЗагрузкаДанных.ЗаписатьСтатусДокумента(Документ, Перечисления.СтатусЗагрузкиДанных.ОшибкаРассчета, ОписаниеОшибки());
						Возврат;
					КонецПопытки;
				Иначе
					Чтение.Закрыть();
					Возврат;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		Строка = Чтение.ПрочитатьСтроку();
		
	КонецЦикла;
	
	Чтение.Закрыть();
	
	Если регСтоимостьУслугСортировки.Количество() > 0 Тогда
		Если Документы.ЗагрузкаДанных.ПрочитатьСтатусДокумента(Документ) = Перечисления.СтатусЗагрузкиДанных.ИдетРассчет Тогда				
			Попытка
				регСтоимостьУслугСортировки.Записать(Ложь);
			Исключение
				Документы.ЗагрузкаДанных.ЗаписатьСтатусДокумента(Документ, Перечисления.СтатусЗагрузкиДанных.ОшибкаРассчета, ОписаниеОшибки());
			КонецПопытки;
		КонецЕсли;
	КонецЕсли;	
	
КонецПроцедуры

Функция ПрочитатьПоля(Строка, ОжидаемоеКолВоПолей = -1) Экспорт
	
	Поля = СтрРазделить(Строка, ",", Истина);
	
	Если ОжидаемоеКолВоПолей <> -1 И ОжидаемоеКолВоПолей <> Поля.Количество() Тогда
		ВызватьИсключение "Неверное число полей";
	КонецЕсли;
	
	СтруктураСтроки = Новый Структура;
	СтруктураСтроки.Вставить("Дата_Убытие", Поля[0]);
	СтруктураСтроки.Вставить("Время_Убытие", Поля[1]);
	СтруктураСтроки.Вставить("НомерГрузовогоМеста", Поля[2]);
	СтруктураСтроки.Вставить("ЗаказКлиента", Поля[3]);
	СтруктураСтроки.Вставить("ИдентификаторЕдиницыОбработки", Поля[4]);
	СтруктураСтроки.Вставить("ОтпСклМс", Поля[5]);
	СтруктураСтроки.Вставить("Дата_Прибытие", Поля[6]);
	СтруктураСтроки.Вставить("Время_Прибытие", Поля[7]);
	СтруктураСтроки.Вставить("КодТипаОбработки", Поля[8]);
	
	Возврат СтруктураСтроки;
	
КонецФункции

#КонецОбласти


#Область СлужебныеПроцедурыИФункции

Функция ЗаполнитьДниХранения(ТаблицаДиапазонов)
	
	Календарь = Константы.ОсновнойКалендарь.Получить();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ТаблицаДиапазонов.ДатаПрибытия КАК ДатаПрибытия,
	|	ТаблицаДиапазонов.ДатаУбытия КАК ДатаУбытия
	|ПОМЕСТИТЬ втТаблицаДиапазонов
	|ИЗ
	|	&ТаблицаДиапазонов КАК ТаблицаДиапазонов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СУММА(ВЫБОР
	|			КОГДА КалендарныеГрафики.ДеньВключенВГрафик
	|				ТОГДА 1
	|			ИНАЧЕ 2
	|		КОНЕЦ) КАК ДнейХранения,
	|	втТаблицаДиапазонов.ДатаПрибытия КАК ДатаПрибытия,
	|	втТаблицаДиапазонов.ДатаУбытия КАК ДатаУбытия
	|ИЗ
	|	втТаблицаДиапазонов КАК втТаблицаДиапазонов
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.КалендарныеГрафики КАК КалендарныеГрафики
	|		ПО (КалендарныеГрафики.ДатаГрафика >= втТаблицаДиапазонов.ДатаПрибытия)
	|			И (КалендарныеГрафики.ДатаГрафика < втТаблицаДиапазонов.ДатаУбытия)
	|ГДЕ
	|	КалендарныеГрафики.Календарь = &Календарь
	|
	|СГРУППИРОВАТЬ ПО
	|	втТаблицаДиапазонов.ДатаПрибытия,
	|	втТаблицаДиапазонов.ДатаУбытия";
	
	Запрос.УстановитьПараметр("Календарь", Календарь);
	Запрос.УстановитьПараметр("ТаблицаДиапазонов", ТаблицаДиапазонов);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	тзДниХранения = РезультатЗапроса.Выгрузить();
	
	тзДниХранения.Индексы.Добавить("ДатаПрибытия");
	тзДниХранения.Индексы.Добавить("ДатаУбытия");
	
	Возврат тзДниХранения;
	
КонецФункции

#КонецОбласти
