
#Область ОбработчикиКомандФормы

&НаКлиенте
Асинх Процедура ВыборФайла(Команда)
	
	ДиалогОткрытия = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);

	ДиалогОткрытия.МножественныйВыбор = Ложь;
	
	ДиалогОткрытия.ПроверятьСуществованиеФайла = Истина;
	
	ДиалогОткрытия.Расширение = ".csv";
	
	Результат = Ждать ДиалогОткрытия.ВыбратьАсинх();
	
	Если ЗначениеЗаполнено(Результат[0]) Тогда
		ИмяФайлаЗагрузки = Результат[0];
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Асинх Процедура ПрочитатьФайл(Команда)
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Сохраните документ";
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	
	Файл = Новый Файл(ИмяФайлаЗагрузки);
	
	ФайлСуществует = Ждать Файл.СуществуетАсинх();
	
	Если НЕ ФайлСуществует Тогда
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Файл не существует";
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	
	ПрочитатьФайлНаСервере(Объект.Ссылка, ИмяФайлаЗагрузки);
	Прочитать();
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьДанные(Команда)
	ОчиститьДанныеНаСервере(Объект.Ссылка);
	Прочитать();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура ПрочитатьФайлНаСервере(Ссылка, ИмяФайла)
	Документы.ЗагрузкаДанных.ПрочитатьФайлДанных(Ссылка, ИмяФайла);
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОчиститьДанныеНаСервере(Ссылка)
	
	Если НЕ ЗначениеЗаполнено(Ссылка) Тогда
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Сохраните документ";
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	
	Документы.ЗагрузкаДанных.ОчиститьДанные(Ссылка);
	
КонецПроцедуры

#КонецОбласти

