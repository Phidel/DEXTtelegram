Игорь
-1001179431786; DEXT Live New Pairs Bot [BSC / Binance Smart Chain]
-1001298556816; DEXT Live New Pairs Bot [Ethereum Blockchain]
1617912213; Олеся Новикова (Ihor)
-1001388749434; BSC Liquidity Pairs
-1001601187141; ETH Liquidity Pairs
1990154044; SAFE Analyzer Bot

---------
Ihor 30.05.2022
Из телеграм канала https://t.me/DEXTNewPairsBotBSC (-1001179431786 --> -1001388749434)
нужно вытаскивать из каждого нового сообщения данные поля "Token contract:" 
и этот контракт отправлять в бота @SafeAnalyzerbot (1990154044)

В ответ бот выдает анализ контракта. 
Нужно в зависимости от анализа или 
  - игнорировать или 
  - отправлять анализ в отдельный ТГ канал, если он проходит фильтры. 

Фильтр пока только один (в дальнейшем может быть больше): зеленый цвет в шапке https://c2n.me/4fN8ifK

то же самое для канала https://t.me/DEXTNewPairsBot (-1001298556816 --> -1001601187141)
используем тот же бот и тот же анализ. но отфильтрованные данные отпраляем в отдельный канал

----
Вы должны в обычном телеграме на выбранном номере подписаться на все нужные каналы и боты (два входных канала, два выходных, и бот анализа). Те каналы в которые программа будет писать сообщения - в них этот номер добавить в админы

принцип работы - программа ждет обновлений от сервера телеграм. Если нет движения по каналам, то и программа не будет ничего отображать в статусной строке и в логе

---
Его сервер
IP-адрес сервера: 45.82.69.191
Пользователь: Administrator
Пароль: CS54ebg3d4tE
--------

Проблема - от этих входных каналов сообщения приходят с большой задержкой
Почему не знаю. Возможно, из-за большого числа подписчиков 24-26 тысяч
Думаю, какая-то ошибка в библиотеке телеграм 
Решила пока переподключением по таймеру

---
вот похожая задача на питоне - пересылка картинок из чата в чат (не работает с картинками)

https://www.cyberforum.ru/python-api/thread2822236.html


Для текстовых сообщений рабочий код следующий:

# -*- coding: utf-8 -*-
 
#
# Copyright Aliaksei Levin (levlam@telegram.org), Arseny Smirnov (arseny30@gmail.com) 2014-2018
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
from ctypes.util import find_library
from ctypes import *
import json
import sys
 
API_KEY = 111111
API_HASH = '........'
PHONE_NUMBER = '+7913212313'
 
# load shared library
tdjson_path = find_library("tdjson") or "tdjson.dll"
 
if tdjson_path is None:
    print('can\'t find tdjson library')
    quit()
tdjson = CDLL(tdjson_path)
 
# load TDLib functions from shared library
td_json_client_create = tdjson.td_json_client_create
td_json_client_create.restype = c_void_p
td_json_client_create.argtypes = []
 
td_json_client_receive = tdjson.td_json_client_receive
td_json_client_receive.restype = c_char_p
td_json_client_receive.argtypes = [c_void_p, c_double]
 
td_json_client_send = tdjson.td_json_client_send
td_json_client_send.restype = None
td_json_client_send.argtypes = [c_void_p, c_char_p]
 
td_json_client_execute = tdjson.td_json_client_execute
td_json_client_execute.restype = c_char_p
td_json_client_execute.argtypes = [c_void_p, c_char_p]
 
td_json_client_destroy = tdjson.td_json_client_destroy
td_json_client_destroy.restype = None
td_json_client_destroy.argtypes = [c_void_p]
 
td_set_log_file_path = tdjson.td_set_log_file_path
td_set_log_file_path.restype = c_int
td_set_log_file_path.argtypes = [c_char_p]
 
td_set_log_max_file_size = tdjson.td_set_log_max_file_size
td_set_log_max_file_size.restype = None
td_set_log_max_file_size.argtypes = [c_longlong]
 
td_set_log_verbosity_level = tdjson.td_set_log_verbosity_level
td_set_log_verbosity_level.restype = None
td_set_log_verbosity_level.argtypes = [c_int]
 
fatal_error_callback_type = CFUNCTYPE(None, c_char_p)
 
td_set_log_fatal_error_callback = tdjson.td_set_log_fatal_error_callback
td_set_log_fatal_error_callback.restype = None
td_set_log_fatal_error_callback.argtypes = [fatal_error_callback_type]
 
# initialize TDLib log with desired parameters
def on_fatal_error_callback(error_message):
    print('TDLib fatal error: ', error_message)
 
td_set_log_verbosity_level(2)
c_on_fatal_error_callback = fatal_error_callback_type(on_fatal_error_callback)
td_set_log_fatal_error_callback(c_on_fatal_error_callback)
 
# create client
client = td_json_client_create()
 
# simple wrappers for client usage
def td_send(query):
    query = json.dumps(query).encode('utf-8')
    td_json_client_send(client, query)
 
def td_receive():
    result = td_json_client_receive(client, 1.0)
    if result:
        result = json.loads(result.decode('utf-8'))
    return result
 
def td_execute(query):
    query = json.dumps(query).encode('utf-8')
    result = td_json_client_execute(client, query)
    if result:
        result = json.loads(result.decode('utf-8'))
    return result
 
td_send({'@type': 'getAuthorizationState', '@extra': 1.01234})
 
chat_ids = []
chats = []
choosen_chat_id = 0
 
non_bmp_map = dict.fromkeys(range(0x10000, sys.maxunicode + 1), 0xfffd)
 
# main events cycle
while True:
    event = td_receive()
    if event:
        # if client is closed, we need to destroy it and create new client
        if event['@type'] == 'updateAuthorizationState' and event['authorization_state']['@type'] == 'authorizationStateClosed':
            break
 
        if event['@type'] in ['updateSupergroup', 'updateNewChat', 'updateChatLastMessage', 'updateUser']:
            continue
        if  event.get('@extra') == 1001001:
            chat_ids = event['chat_ids']
            for chat_id in chat_ids:
                td_send({'@type':'getChat', 'chat_id':chat_id, 'extra':1001011})
        if event['@type'] == 'updateNewMessage' and event['message']['chat_id'] == choosen_chat_id:
            
            message_type = event['message']['content']['@type']
            print("*"*80)
            print("Получено:", message_type)
            print("-"*80)
            if message_type == 'messageText':
                message_text = event['message']['content']['text']['text'].translate(non_bmp_map)
                print(message_text)
                
                td_send({'@type':'sendMessage', 'chat_id':target_chat_id, 'input_message_content': {
                         '@type': 'inputMessageText',
                         'text': {
                         '@type': 'formattedText',
                         'text': message_text
                        }}}
                         )
                
                
            print("-"*80)
            print(event)
            
            print("*"*80)
            
        if event['@type'] == 'chat':
            title = event['title'].translate(non_bmp_map)
            print('Получен чат', len(chats),  title, event['id'])
            chats.append({'title': title, 'id': event['id']})
            if len(chats) == len(chat_ids):
                chat_id = int(input('Выберите чат для мониторинга (1 - {m_ch})'.format(m_ch=len(chats))))
                print("Выбран чат", chats[chat_id])
                choosen_chat_id = chats[chat_id]['id']
 
                chat_id = int(input('Выберите чат для пересылки (1 - {m_ch})'.format(m_ch=len(chats))))
                print("Выбран чат", chats[chat_id])
                target_chat_id = chats[chat_id]['id']
 
                if target_chat_id == choosen_chat_id:
                    print("Нельзя два раза выбрать одно и то же!!!!")
                    break
                
        if event['@type'] == "authorizationStateWaitTdlibParameters":
            td_send({'@type': 'setTdlibParameters',
            'parameters': {'use_test_dc': False,
            'api_id':API_KEY,
            'api_hash': API_HASH,
            'device_model': 'Desktop',
            'system_version': 'Unknown',
            'application_version': "0.0",
            'system_language_code': 'en',
            'database_directory': 'Database',
            'files_directory': 'Files',
            'use_file_database': True,
            'use_chat_info_database': True,
            'use_message_database': True,
            }
            })
            td_send({'@type': 'checkDatabaseEncryptionKey',})
            
        elif event['@type'] == 'updateAuthorizationState' and  event['authorization_state']['@type'] == 'authorizationStateWaitPhoneNumber':
            td_send({'@type': 'setAuthenticationPhoneNumber', 'phone_number': PHONE_NUMBER})
 
        elif event['@type'] == 'updateAuthorizationState' and  event['authorization_state']['@type'] == 'authorizationStateWaitCode':
            code = input("Enter code:")
            td_send({'@type': 'checkAuthenticationCode', 'code': code})
 
        elif event['@type'] == 'updateAuthorizationState'    and  event['authorization_state']['@type'] == 'authorizationStateReady':
            td_send({'@type': 'getChats',  'limit': 100, 'offset_order':2**63-1, '@extra': 1001001})
            td_send({'@type': 'getMe', '@extra': 1001111})
            
        sys.stdout.flush()
 
td_json_client_destroy(client)

Пытался переделать под пересылку картинки, никак не получается, а инфа по этой библиотеке скудная, даже на английском немного, а примеров с картинками вообще нет.

if message_type == 'messagePhoto'
...
photo_id == event['message']['content']['photo']['sizes'][0]['photo']['remote']
td_send({'@type':'sendMessage', 'chat_id':target_chat_id, 'input_message_content': {
                         '@type': 'inputMessagePhoto',
                         'photo': {
                            # здесь разные варианты пробовал, не работают
                        }}}
                         )
Не знаю как указать чтобы пересылал фото по id (пробовал и локальный id, и remote), пробовал inputMessageDocument в связке с openFile

--
Касаемо пересылки фото, несколько топорно, но работает:

if message_type == 'messagePhoto':
                message_photo = event['message']['content']['photo']
                photo_size = message_photo['sizes'][0]
                
                print(photo_size['photo']['remote']['id'])

                td_send({'@type': 'sendMessage', 'chat_id': target_chat_id, 'input_message_content': {
                    '@type': 'inputMessagePhoto',
                    'photo': {
                        '@type': 'inputFileRemote',
                        'id': photo_size['photo']['remote']['id']
                    }}}
                        )