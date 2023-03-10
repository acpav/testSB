#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаполнитьПоУмолчанию(Команда)
	ЗаполнитьПоУмолчаниюНаСервере();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура ЗаполнитьПоУмолчаниюНаСервере()
	
	МассивДанных = Новый Массив();

	МассивДанных.Добавить(Новый Структура("СреднедневноеКоличествоГрузовыхМест, Стоимость", 500, 500));
	МассивДанных.Добавить(Новый Структура("СреднедневноеКоличествоГрузовыхМест, Стоимость", 1000, 200));
	МассивДанных.Добавить(Новый Структура("СреднедневноеКоличествоГрузовыхМест, Стоимость", 2000, 100));
	МассивДанных.Добавить(Новый Структура("СреднедневноеКоличествоГрузовыхМест, Стоимость", 5000, 70));
	МассивДанных.Добавить(Новый Структура("СреднедневноеКоличествоГрузовыхМест, Стоимость", 9999999999, 50));

	ДатаЗаписи = Дата(2022, 08, 01);
			
	Для Каждого эл Из МассивДанных Цикл
		рег = РегистрыСведений.ТарифыОбработкиХабов.СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(рег, эл);
		рег.Период = ДатаЗаписи;
		рег.Записать(); 
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
