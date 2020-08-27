local screen = Vector2( guiGetScreenSize() );
loadstring(exports.dgs:dgsImportOOPClass(true))()

local windowCrude;

function CreateUI()
	
	if toggle then
	
		toggle = false;
		
		destroyElement( windowCrude );
		
		showCursor( false );
		
		RemoveEvents();
		
	else
	
		toggle = true
		
		local listPlayers = {};

		windowCrude 		= dgsCreateWindow( screen.x / 2 - 500 / 2, screen.y / 2 - 500 / 2, 500, 420, "DNaumov CRUD", false );
		
		addEventHandler( "onDgsWindowClose", windowCrude, function()
			toggle = false;
			
			showCursor( false );
		
			destroyElement( windowCrude );
			
			RemoveEvents();
		end, false );
	
		local gridListWidth = 500 - 30 * 2;
		local gridListCrude = dgsCreateGridList( 30, 30, gridListWidth, 250, false, windowCrude );
	
		dgsGridListAddColumn( gridListCrude, "Имя пользователя", 0.3 );
		dgsGridListAddColumn( gridListCrude, "Фамилия пользователя", 0.38 );
		dgsGridListAddColumn( gridListCrude, "Адрес проживания", 0.3 );
	
		-- Взаимодействие со спиком.
		local function AddUserCrud( user )
			
			local row = dgsGridListAddRow( gridListCrude );
	
			dgsGridListSetItemText( gridListCrude, row, 1, user.name );
			dgsGridListSetItemText( gridListCrude, row, 2, user.last_name );
			dgsGridListSetItemText( gridListCrude, row, 3, user.address );
		
			user.row_id = row;
		
			listPlayers[ user.id ] = user;
		end
		addEvent( "onClientAddUserCrud", true );
		
		local function RemoveUser( user )
			for i, v in pairs( listPlayers ) do
				if ( v.id == user.id ) then
				
					listPlayers[ i ] = nil;
					dgsGridListRemoveRow( gridListCrude, v.row_id );
					
					break;
				end
			end
		end
		addEvent( "onClientRemoveUserCrud", true );
		
		local function EditUser( newUserData )
			for i, v in pairs( listPlayers ) do
				if ( v.id == newUserData.id ) then
				
					local row = v.row_id;
					
					dgsGridListSetItemText( gridListCrude, row, 1, newUserData.name );
					dgsGridListSetItemText( gridListCrude, row, 2, newUserData.last_name );
					dgsGridListSetItemText( gridListCrude, row, 3, newUserData.address );
					
					for k, value in pairs( newUserData ) do
						listPlayers[ i ][ k ] = value;
					end
					
					break;
				end
			end
		end
		addEvent( "onClientEditUserCrud", true );
		
		function GetUserIdRow( id )
			for i, v in pairs( listPlayers ) do
			
				if ( v.row_id == id ) then
					return v.id;
				end
				
			end
			return nil;
		end
		local function GetSelectedUserID()
			local rowSelected = dgsGridListGetSelectedItem( gridListCrude );
			
			if ( rowSelected == - 1 ) then
			
				return false;
			end
			
			local userID = GetUserIdRow( rowSelected );
			outputChatBox(userID)
			
			if ( not userID ) then
				return false;
			end
			return userID;
		end
		local function GetUserSelected()
		
			local userID = GetSelectedUserID();
			
			if ( not userID ) then
				return;
			end
			
			
			for i, v in pairs( listPlayers ) do
			
				if ( v.id == userID ) then
					return v;
				end
				
			end
			return;
		end
		-- [[ ПОИСК 1 ]] --
		local btnSearch1 = dgsCreateEdit( 30, 300, 100, 30, "", false, windowCrude );
		-- [[ ПОИСК 2 ]] --
		local btnSearch2 = dgsCreateEdit( 140, 300, 100, 30, "", false, windowCrude );
		-- [[ ПОИСК 2 ]] --
		local btnSearch3 = dgsCreateEdit( 250, 300, 100, 30, "", false, windowCrude );
		-- [[ КНОПКА ПОИСКА ]] --
		local btnStartSearch = dgsCreateButton( 360, 300, 100, 30, "ПОИСК", false, windowCrude );
		
		addEventHandler ( "onDgsMouseClickUp", btnStartSearch, function( btn )
		
			local SearchName  = dgsGetText( btnSearch1 );
			local SearchLastName  = dgsGetText( btnSearch2 );
			local SearchAdress  = dgsGetText( btnSearch3 );
			
			if ( utf8.len( SearchName ) == 0 and utf8.len( SearchLastName ) == 0 and utf8.len( SearchAdress ) == 0) then
				request = 'SELECT id, name, last_name, address FROM users';
			end
			
			searchColumn = 0;
			request = 'SELECT * FROM users ';
			
			
			local args = {};
			local conditions = {};

			if ( utf8.len ( SearchName ) >= 1 ) then
				table.insert(conditions, " `??` = ?");
				table.insert(args, 'name');
				table.insert(args, SearchName);
			end

			if ( utf8.len ( SearchLastName ) >= 1 ) then
				table.insert(conditions, " `??` = ?");
				table.insert(args, 'last_name');
				table.insert(args, SearchLastName);
			end

			if ( utf8.len ( SearchAdress ) >= 1 ) then
				table.insert(conditions, " `??` = ?");
				table.insert(args, 'address');
				table.insert(args, SearchAdress);
			end
			
			local sQuery = "SELECT * FROM `users` WHERE"..table.concat(conditions, " AND ").. " ";
			local pQuery = unpack(args);
			print (unpack(args))
			
			dgsGridListClear (gridListCrude)

			triggerServerEvent('onPlayerSearch',localPlayer, sQuery, pQuery);
		
		end, false	);
	
		-- [[ КНОПКА РЕДАКТИРОВАТЬ ]] --
		local btnEditUser = dgsCreateButton( 30, 350, 100, 30, "Редактировать", false, windowCrude );
	
		addEventHandler ( "onDgsMouseClickUp", btnEditUser, function( btn )
		
			if btn ~= "left" then
				return;
			end
			
			local user = GetUserSelected();
		
			if ( not user ) then
				ErrorBox( "Выберите пользователя!" );
				return;
			end
		
			EditUserI( user );
			dgsSetVisible( windowCrude, false );
		end, false	);
	
		-- [[ КНОПКА УДАЛИТЬ ]] --
		local btnRemoveUser = dgsCreateButton( 30 + gridListWidth / 2 - 100 / 2, 350, 100, 30, "Удалить", false, windowCrude );
	
		addEventHandler ( "onDgsMouseClickUp", btnRemoveUser, function( btn )
		
			if btn ~= "left" then
				return;
			end
			
			local userID = GetSelectedUserID();
		
			if not userID then
				ErrorBox( "Выберите пользователя!" );
				return;
			end
		
			RemoveUserI( userID );
			dgsSetVisible( windowCrude, false );
		end, false	);
	
		-- [[ КНОПКА ДОБАВИТЬ ]] --
		local btnAddUser = dgsCreateButton( 30 + gridListWidth - 100, 350, 100, 30, "Добавить", false, windowCrude );
	
		addEventHandler ( "onDgsMouseClickUp", btnAddUser, function( btn )
			if btn ~= "left" then
				return;
			end

			AddUser( );
			dgsSetVisible( windowCrude, false );
			
		end, false	);
		
	
		-- Обработка всех событий из сервера.
		AddRPCEvent( "onClientAddUserCrud", AddUserCrud );
		AddRPCEvent( "onClientRemoveUserCrud", RemoveUser );
		AddRPCEvent( "onClientEditUserCrud", EditUser );
		
		
		addEvent( "onClientReciveUsers", true );
		AddRPCEvent( "onClientReciveUsers", function( listPlayers )
			for i, v in ipairs( listPlayers ) do
				AddUserCrud( v );
			end
		end );
	
		ServerCall( "onPlayerRequestListUsers" );
	
		showCursor( true );
	end
end
bindKey('l', 'down', CreateUI)

function AddUser( )

	local windowCrudeUserAdd = dgsCreateWindow( screen.x / 2 - 200 / 2, screen.y / 2 - 250 / 2, 200, 250, "Новый пользователь", false );

	local editNameUser = dgsCreateEdit( 20, 20, 200 - 20 * 2, 30, "Имя", false, windowCrudeUserAdd );
	local editLastNameUser = dgsCreateEdit( 20, 60, 200 - 20 * 2, 30, "Фамилия", false, windowCrudeUserAdd );
	local editAddressUser = dgsCreateEdit( 20, 100, 200 - 20 * 2, 30, "Адрес", false, windowCrudeUserAdd );
	
	local buttonAddUser = dgsCreateButton( 200 / 2 - 100 / 2, 150, 100, 30, "Добавить", false, windowCrudeUserAdd );
	
	addEventHandler ( "onDgsMouseClickUp", buttonAddUser, function( btn )
		
		if btn ~= "left" then
			return;
		end
		
		local name  = dgsGetText( editNameUser );
		local lastName  = dgsGetText( editLastNameUser );
		local address  = dgsGetText( editAddressUser );
		
		if ( utf8.len( name ) == 0 or utf8.len( lastName ) == 0 or utf8.len( address ) == 0 ) then
			ErrorBox( "Введите все данные пользователя!" );
			return;
		end
		
		destroyElement(windowCrudeUserAdd);
		dgsSetVisible( windowCrude, true );
		
		
		ServerCall( "onPlayerAddUser", { name = name, last_name = lastName, address = address } );
	end, false	);
end

function RemoveUserI( userID )
	local windowCrudeRemoveUser = dgsCreateWindow( screen.x / 2 - 300 / 2, screen.y / 2 - 200 / 2, 300, 120, "Вы уверены?", false );
	
	local buttonNo = dgsCreateButton( 30, 50, 100, 30, "Нет", false, windowCrudeRemoveUser );
	
	addEventHandler ( "onDgsMouseClickUp", buttonNo, function( btn )
		if btn ~= "left" then
			return;
		end
		
		destroyElement( windowCrudeRemoveUser );
		dgsSetVisible( windowCrude, true );
	end, false	);
	
	local buttonYes = dgsCreateButton( 300 - 30 - 100, 50, 100, 30, "Да", false, windowCrudeRemoveUser );
	
	addEventHandler ( "onDgsMouseClickUp", buttonYes, function( btn )
		if btn ~= "left" then
			return;
		end
		
		destroyElement( windowCrudeRemoveUser );
		dgsSetVisible( windowCrude, true );
		
		ServerCall( "onPlayerRemoveUser", { id = userID } );
	end, false	);
end

function ErrorBox ( text )
	local windowCrudeError = dgsCreateWindow( screen.x / 2 - 300 / 2, screen.y / 2 - 100 / 2, 300, 100, "Ошибка", false );
	
	dgsCreateLabel(20,10,200,200,text,false,windowCrudeError)
	
	local buttonCloseError = dgsCreateButton( 300 / 2 - 100 / 2, 40, 100, 30, "OK", false, windowCrudeError );
	
	addEventHandler ( "onDgsMouseClickUp", buttonCloseError, function( btn )
		
		if btn ~= "left" then
			return;
		end
		
		destroyElement(windowCrudeError)
		dgsSetVisible( windowCrude, true );
	end, false	);
end

function EditUserI( user )
	local windowCrudeEditUser = dgsCreateWindow( screen.x / 2 - 200 / 2, screen.y / 2 - 200 / 2, 200, 220, "Редактировать пользователя", false );
	
	addEventHandler( "onDgsWindowClose", windowCrudeEditUser, function()
		cancelEvent();
		
		destroyElement( windowCrudeEditUser );
	end, false );
	
	local editWidth = 200 - 20 * 2;
	
	local editName = dgsCreateEdit( 20, 20, editWidth, 30, user.name, false, windowCrudeEditUser );
	local editLastName = dgsCreateEdit( 20, 60, editWidth, 30, user.last_name, false, windowCrudeEditUser );
	local editAddress = dgsCreateEdit( 20, 100, editWidth, 30, user.address, false, windowCrudeEditUser );
	
	local buttonAdd = dgsCreateButton( 200 / 2 - 100 / 2, 150, 100, 30, "Сохранить", false, windowCrudeEditUser );
	
	addEventHandler ( "onDgsMouseClickUp", buttonAdd, function( btn )
		if btn ~= "left" then
			return;
		end
		
		local name  = dgsGetText( editName );
		local lastName  = dgsGetText( editLastName );
		local address  = dgsGetText( editAddress );
		
		if ( utf8.len( name ) == 0 or utf8.len( lastName ) == 0 or utf8.len( address ) == 0 ) then
			ShowError( "Введите все данные пользователя!" );
			
			return;
		end
		
		destroyElement( windowCrudeEditUser );
		dgsSetVisible( windowCrude, true );
		
		ServerCall( "onPlayerEditUser", { id = user.id, name = name, last_name = lastName, address = address } );
	end, false	);
end