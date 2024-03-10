DataDef home_bases
    "00000000011111111000000000011111111000000000011111111000000000011111111000000000"
    "00000000111111111100000000111111111100000000111111111100000000111111111100000000"
    "00000000111000011100000000111000011100000000111000011100000000111000011100000000"
    "00000000111000011100000000111000011100000000111000011100000000111000011100000000"
end

DataDef rank_names
    ""
    "rookie"
    "earthling"
    "space cadet"
    "yeoman"
    "lieutenant"
    "commander"
    "captain"
    "admiral"
    "master assassin"
end

proc srand(integer multiplier)
    integer hrs
           ,minutes
           ,sec
           ,hun

    if multiplier == 0                    //Randomize using system clock
        GetTime(hrs,minutes,sec,hun)
        multiplier = sec * 100 + hun
        multiplier = multiplier * 0ffffh / 5999
    else
        multiplier = multiplier & 0ffffh  //Must not be greater than 0ffffh
    endif

    multiplier = multiplier | 1           //Add 1 if even to make it odd
    SetGlobalInt("randproc_multiplier",multiplier)
end

integer proc rand()
            integer seed       = 37584381
                   ,multiplier = GetGlobalInt("randproc_multiplier")
                   ,result

            result = seed * multiplier
            multiplier = result & 0ffffh
            SetGlobalInt("randproc_multiplier",multiplier)
            result = result & 0ffff00h
            result = result shr 8
            return(result)
        end

proc flash(integer attr)
    integer i = 0

    while i < 25
        i = i + 1
        GotoXY(1,i)
        PutAttr(attr,80)
    endwhile
end

integer barrier_id

integer proc barrier_get(integer subscript1,integer subscript2)
            GotoBufferId(barrier_id)
            GotoLine(subscript1 + 1)
            return(Val(GetText(subscript2 + 1,1)))
        end

integer barr_id

proc barr_put(integer subscript1,integer subscript2,integer value)
    GotoBufferId(barr_id)
    GotoLine(subscript1 + 1)
    GotoColumn(subscript2 + 1)
    InsertText(Format(value:1),_OVERWRITE_)
end

integer proc barr_get(integer subscript1,integer subscript2)
            GotoBufferId(barr_id)
            GotoLine(subscript1 + 1)
            return(Val(GetText(subscript2 + 1,1)))
        end

integer bmb_id

proc bmb_put_col(integer subscript,integer value)
    GotoBufferId(bmb_id)
    GotoLine(1)
    GotoColumn((subscript * 2) + 1)
    InsertText(Format(value:2),_OVERWRITE_)
end

integer proc bmb_get_col(integer subscript)
            GotoBufferId(bmb_id)
            GotoLine(1)
            return(Val(GetText((subscript * 2) + 1,2)))
        end

proc bmb_put_row(integer subscript,integer value)
    GotoBufferId(bmb_id)
    GotoLine(2)
    GotoColumn((subscript * 2) + 1)
    InsertText(Format(value:2),_OVERWRITE_)
end

integer proc bmb_get_row(integer subscript)
            GotoBufferId(bmb_id)
            GotoLine(2)
            return(Val(GetText((subscript * 2) + 1,2)))
        end

integer al_id

proc al_put_col(integer subscript,integer value)
    GotoBufferId(al_id)
    GotoLine(1)
    GotoColumn((subscript * 2) + 1)
    InsertText(Format(value:2),_OVERWRITE_)
end

integer proc al_get_col(integer subscript)
            GotoBufferId(al_id)
            GotoLine(1)
            return(Val(GetText((subscript * 2) + 1,2)))
        end

proc al_put_row(integer subscript,integer value)
    GotoBufferId(al_id)
    GotoLine(2)
    GotoColumn((subscript * 2) + 1)
    InsertText(Format(value:2),_OVERWRITE_)
end

integer proc al_get_row(integer subscript)
            GotoBufferId(al_id)
            GotoLine(2)
            return(Val(GetText((subscript * 2) + 1,2)))
        end

integer ranks_id

string  proc name_get()
            GotoBufferId(ranks_id)
            Down()
            return(GetText(1,15))
        end

/*
 * Aliens -- an animated video game
 *      the original version is from
 *      Fall 1979                       Cambridge               Jude Miller
 */

/* global variables */

integer scores,bases,game
integer i,j,danger,max_danger
integer iflip,flop,ileft,al_num,b
integer al_cnt, bmb_cnt, bmb_max, spread
integer slow
integer level
string command[1]   = ""
string smessage[100] = ""
integer bas_row, bas_col, bas_vel
integer bem_row, bem_col
integer shp_val, shp_col, shp_vel
integer current_id
       ,mode

forward         proc main1()
forward         proc replay()
forward         proc init()
forward         proc instruct()
forward         proc tabl()
forward         proc poll()
forward         proc clr()
forward         proc base()
forward         proc beam()
forward         proc bomb()
forward         proc ship()
forward         proc alien()
forward         proc scoreit()
forward         proc gauntlet()
forward         proc over()
forward         proc setpos(integer row,integer col)
forward string  proc getchar()
forward integer proc kbhit()
forward         proc ds_obj(integer class)

/*
 * main -- scheduler and main entry point for aliens
 */

proc main()
        PopWinOpen(1, 1, Query(ScreenCols), Query(ScreenRows), 1, "", 0)
        PushBlock()
        HideMouse()
        mode       = Query(CurrVideoMode)

        if mode <> _25_lines_
            Set(CurrVideoMode,_25_lines_)
        endif

        command    = ""
        current_id = GetBufferid()

        al_id      = CreateTempBuffer()
        InsertLine()
        InsertLine()

        bmb_id     = CreateTempBuffer()
        InsertLine()
        InsertLine()

        barr_id    = CreateTempBuffer()
        InsertLine()
        InsertLine()
        InsertLine()
        InsertLine()

		level      = 0
		main1()

        AbandonFile(ranks_id)
        AbandonFile(barrier_id)
        AbandonFile(barr_id)
        AbandonFile(bmb_id)
        AbandonFile(al_id)

        GotoBufferId(current_id)
        ShowMouse()

        if mode <> _25_lines_
            Set(CurrVideoMode,mode)
        endif

        PopBlock()
        PopWinClose()
        //UpdateDisplay(_ALL_WINDOWS_REFRESH_)
end

/*	main program loop and replay entry point */

proc main1()
	srand(0)  /* start rand randomly */
	init()
    if command == "q"
            return()
    endif
	while true
		tabl()
		while true
			poll()
            if command == "q"
            		return()
            endif
			beam()
			beam()
			beam()
			base()
			bomb()
			ship()
			if game <> 4
				alien()
            endif
			if game == 2
				alien()
            endif
			alien()
			if (al_cnt == 0) and (bmb_cnt == 0)
				break
            endif
		endwhile
		gauntlet()
	endwhile
end

proc replay()
	setpos(23,0)
	main1()
end

/*
 * init -- does global initialization
 */

proc init()
	scores = 0
	bmb_cnt = 0
	slow = 0
    barrier_id = CreateTempBuffer()
    InsertData(home_bases)
    ranks_id = CreateTempBuffer()
    InsertData(rank_names)

	/* do terminal dependent initialization */

    Set(Cursor,off)

	/* new game starts here */

	game = 0
	instruct()

	while game==0
	    poll()
            if command == "q"
                    return()
            endif
        endwhile

	scores = 0
	bases = 3
	max_danger = 22
end

/*
 * instructions -- print out instructions
 */

proc instruct()
    Set(Attr,7)
	clr()
	setpos(0,0)
	WriteLine("Attention: Alien invasion in progress!")
	setpos(0,0)
    PutAttr(12, 10)
	setpos(0,11)
    PutAttr(14, 27)
	setpos(1,0)
    WriteLine("")
	WriteLine("        Type:   <,>     to move the laser base left")
	WriteLine("                <z>     as above, for lefties")
	WriteLine("                <.>     to halt the laser base")
	WriteLine("                <x>     for lefties")
	WriteLine("                </>     to move the laser base right")
	WriteLine("                <c>     for lefties")
	WriteLine("                <space> to fire a laser beam")
    WriteLine("")
	WriteLine('                <1>     to play "Bloodbath"')
	WriteLine('                <2>     to play "We come in peace"')
	WriteLine('                <3>     to play "The Aliens strike back"')
	WriteLine('                <4>     to play "Invisible Alien Weasels"')
	WriteLine('                <5>     to play "Klinker"')
	WriteLine('                <6>     to play "The Black Hole"')
	WriteLine("                <q>     to quit")
    WriteLine("")
end

/*
 * tabl -- tableau draws the starting game tableau.
 */

proc tabl()
	clr()
    Set(Attr,2)
	setpos(0,0)
	smessage = Format("Level:",level:2," ")
	Write(smessage)
	smessage = Format("Score: ",scores:-5," ")
	Write(smessage)
	case game
	when 1
		Write("               B L O O D B A T H             ")
	when 2
		Write("        W E  C O M E  I N  P E A C E !       ")
	when 3
		Write("T H E   A L I E N S   S T R I K E   B A C K !")
	when 4
		Write("I N V I S I B L E  A L I E N  W E A S E L S !")
	when 5
		Write("              K L I N K E R                  ")
	when 6
		Write("     T H E   B L A C K   H O L E !          ")
	endcase

	setpos(0,70)
	if game >= 3
		smessage = Format("Bases: ",bases)
		Write(smessage)
        endif

	/* initialize alien co-ords, display */

	al_cnt = 55
	danger = level + 11
	if danger > max_danger
		danger = max_danger
    endif
	bmb_max = level + 5
	if bmb_max > 10
		bmb_max = 10
    endif
	spread = level/2
    j=0
	while j<=4
		setpos(danger-(2*j),0)
        i=0
		while i<=10
			ds_obj(((i+j)&1)+(2*(j/2)))
			Putstr(" ")
            al_put_row((11*j)+i,danger - (2*j))
            al_put_col((11*j)+i,(6*i))
            i = i + 1
		endwhile
        j = j + 1
	endwhile
	al_num = 54
	iflip = 0
	flop = 0
	ileft = 0

	/* initialize laser base position and velocity */

    bas_row = 23
    bas_col = 72
	if rand() < 10000
		bas_col = 1
    endif
	bas_vel = 0
	bem_row = 0
	if game < 6
		setpos(bas_row,bas_col)
		ds_obj(7)
	endif

	/* initialize bomb arrays (row = 0 implies empty) */

    i = 0
	while i<bmb_max
		bmb_put_row(i, 0)
        i = i + 1
    endwhile
	b = 0
	bmb_cnt = 0

	/* initialize barricades */

	i = 0
	while i<=3
		setpos(i+19,0)
        j=0
		while j<80
            barr_put(i,j,barrier_get(i,j))
			if barr_get(i,j)
				ds_obj(8)
			else
				Putstr(" ")
            endif
            j=j+1
        endwhile
    	i = i + 1
	endwhile

	/* initialize mystery ships */

	shp_vel = 0
end

/*
 * poll -- read input characters and set global flags
 */

proc poll()
	if game==1
		if bas_col >= 72-level
			bas_vel = -1
        endif
		if bas_col <= 1
		        bas_vel = 1
        endif
	endif
	if not kbhit()
		return()
    endif
	command = getchar()
	Lower(command)
	case command
	when 'z',','
		if game==1
			return()
        endif
		bas_vel = -1
	when 'c','/'
		if game==1
			return()
        endif
		bas_vel = 1
	when 'x','.'
		if game==1
			return()
        endif
		bas_vel = 0
	when ' '
		if bem_row==0
			bem_row = 22
        endif
    when 'q'
        over()
	when '1'
		if game<>0
			return()
        endif
		game = 1
	when '2'
		if game<>0
			return()
        endif
		game = 2
	when '3'
		if game<>0
			return()
        endif
		game = 3
	when '4'
		if game<>0
			return()
        endif
		game = 4
	when '5'
		if game<>0
            return()
        endif
		game = 5
	when '6'
		if game<>0
			return()
        endif
		game = 6
	endcase
end

/*
 * clr -- issues an escape sequence to clear the display
 */

proc clr()
        ClrScr()
end

/*
 * ds_obj -- display an object
 */

proc ds_obj(integer class)
	if (game>=4)and(class>=0)and(class<=5)
		class = 6
    endif
	case class
        when 0
                Putstr(" OXO ")
        when 1
                Putstr(" XOX ")
        when 2
                Putstr(" \o/ ")
        when 3
                Putstr(" /o\ ")
        when 4
                Putstr(' "M" ')
        when 5
                Putstr(" wMw ")
        when 6
                Putstr("     ")
        when 7
                Putstr(" xx|xx ")
        when 8
				if game >= 5
						return()
        		endif
				Putstr("#")
	endcase
end

/*
 * base -- move the laser base left or right
 */

proc base()
	if bas_vel == 0
		return()
    endif
	bas_col = bas_col + bas_vel
	if bas_col < 1
			bas_col = 1
			bas_vel = 0
	else if bas_col > 72
			bas_col = 72
			bas_vel = 0
		endif
    endif
	if game < 6
		setpos(bas_row,bas_col)
		ds_obj(7)
	endif
end

/*
 * beam -- activate or advance the laser beam if required
 */

proc beam()
	integer points

	/* display beam */

	case bem_row
	when 23,0
		setpos(21,bem_col) /* Kill some time */
		Write("")
		setpos(21,bem_col) /* Kill some time */
		Write("")
		setpos(21,bem_col) /* Kill some time */
		Write("")
		return()
	when 22
		bem_col = bas_col + 3
		setpos(22,bem_col)
		Putstr("|")
		setpos(22,bem_col)
        PutAttr(3,1)
	otherwise
		setpos(bem_row,bem_col)
		Putstr("|")
		setpos(bem_row,bem_col)
        PutAttr(3,1)
		setpos(bem_row+1,bem_col)
		Putstr(" ")
	endcase

	/* check for contact with an alien */

	i = 0
	while i<55
		if (al_get_row(i)==bem_row) and ((al_get_col(i)+1)<=bem_col)
			and ((al_get_col(i)+3)>=bem_col)

			/* contact! */

			points = 1 + (i/22) + (level*(i/11))
			if game <> 1
				points = points - slow
            endif
			if points <= 1
				points = 1
            endif
			scores = scores + points
			scoreit()
			setpos(bem_row+1,bem_col)
			Putstr(" ")
			if game >= 4
            	Alarm()
            endif
			setpos(al_get_row(i),al_get_col(i))
			ds_obj(6)      /* erase beam and alien */
			bem_row=0
			al_put_row(i,0)    /* clear beam and alien state */
			al_cnt = al_cnt - 1
			return()
		endif
        i = i + 1
	endwhile

	/* check for contact with a bomb */

	i = 0
	while i<bmb_max
		if (bem_row==bmb_get_row(i)) and (bem_col==bmb_get_col(i))
			setpos(bem_row,bem_col)
			Putstr(" ")
			setpos(bem_row+1,bem_col)
			Putstr(" ")
			bem_row = 0
			bmb_cnt = bmb_cnt - 1
			bmb_put_row(i,0)
			return()
		endif
        i = i + 1
	endwhile

	/* check for contact with a barricade */

	if (bem_row>=19) and (bem_row<=22) and barr_get(bem_row-19,bem_col)
		setpos(bem_row,bem_col)
		if game == 2
			ds_obj(8)
		else
			barr_put(bem_row-19,bem_col,0)
			Putstr(" ")
		endif
		if bem_row <> 22
			setpos(bem_row+1,bem_col)
			Putstr(" ")
        endif
		bem_row = 0
		return()
	endif

	/* check for contact with a mystery ship */

	i=shp_col-shp_vel
	if (shp_vel<>0) and (bem_row==1) and (bem_col>i)
		and (bem_col<i+7)

		/* contact! */

		setpos(1,i)
		Putstr(" <BOOM!> ")
        flash(142)
        Alarm()
        Delay(1)
        flash(2)
		setpos(1,i)
		Putstr("        ")    /* erase ship */
		shp_vel = 0
		scores = scores + shp_val/3
		scoreit()
		setpos(2,bem_col)
		Putstr(" ")
		bem_row = 0
		return()
	endif

	/* check for air ball */

	bem_row = bem_row - 1
	if bem_row==0
		setpos(1,bem_col)
		Putstr(" ")
		setpos(2,bem_col)
		Putstr(" ")
		scores = scores - (level + 1)
		scoreit()
	endif
end

/*
 * bomb -- advance all active bombs
 */

proc bomb()
	b = 0
	while b<bmb_max
		if bmb_cnt == 0
			return()
        endif
		if bmb_get_row(b) == 0
                goto bmb_end_while
        endif

		/* advance bomb, check for hit and display */

		bmb_put_row(b,bmb_get_row(b) + 1)
		if bmb_get_row(b)==23
			setpos(bmb_get_row(b)-1,bmb_get_col(b))
			Putstr(" ")
			bmb_put_row(b,0)
			if (bmb_get_col(b)>bas_col) and
				(bmb_get_col(b)<=(bas_col+5))

				/* the base is hit! */

				if game > 5
					setpos(bas_row,bas_col)
					ds_obj(7)
				endif
				bases = bases - 1
				setpos(0,70)
				smessage = Format("Bases: ",bases)
				Putstr(smessage)
				scores = scores - 25
				scoreit()
				if bases==0
					replay() /* game is over */
                if command == "q"
                    return()
                endif
				endif
				Delay(20)
				setpos(23,bas_col)
				Putstr("       ")
				bas_col = 72
				if rand() < 13000
					bas_col = 1
                endif
				if game < 6
					setpos(23,bas_col)
					ds_obj(7)
				endif
			endif
            goto bmb_end_while
		endif
		if (bmb_get_row(b)>=19) and (bmb_get_row(b)<23)
			and barr_get(bmb_get_row(b)-19,bmb_get_col(b))

			/* the bomb has hit a barricade */

			setpos(bmb_get_row(b)-1,bmb_get_col(b))
			Putstr(" ")
			setpos(bmb_get_row(b),bmb_get_col(b))
			Putstr(" ")
			barr_put(bmb_get_row(b)-19,bmb_get_col(b),0)
			bmb_put_row(b,0)
			bmb_cnt = bmb_cnt - 1
			goto bmb_end_while
		endif
		setpos(bmb_get_row(b)-1,bmb_get_col(b))
		Putstr(" ")
		if bmb_get_row(b)==23
			bmb_cnt = bmb_cnt - 1
			bmb_put_row(b,0)
		else
			setpos(bmb_get_row(b),bmb_get_col(b))
			Putstr("*")
			setpos(bmb_get_row(b),bmb_get_col(b))
            PutAttr(14,1)
        endif
bmb_end_while:  b = b + 1
	endwhile
end

/*
 * ship -- create or advance a mystery ship if desired
 */

proc ship()
	integer vs_cols

	vs_cols = 80
	if shp_vel==0
		i=rand()
		if i<96
			/* create a mystery ship */
			if i<48
				shp_vel = 1
				shp_col = 1
			else
				shp_vel = -1
				shp_col = vs_cols - 8
			endif
			shp_val=90
		endif
	else

		/* update existing mystery ship */

		setpos(1,shp_col)
		if game<=3
				smessage = Format("  <=",shp_val/3,"=>  ")
				Putstr(smessage)
        endif
		shp_val = shp_val - 1
		shp_col = shp_col + shp_vel
		i=shp_col
		if i>(vs_cols-8) or (i<1)

			/* remove ship */

			setpos(1,shp_col-shp_vel)
			Putstr("        ")
			shp_vel = 0
		endif
	endif
end

/*
 * alien -- advance the next alien
 */

proc alien()
	loop
		al_num = al_num + 1
		if al_num >= 55
			if al_cnt==0
				return() /* check if done */
			endif
			flop = 0
			if iflip
				ileft = 1 - ileft
				flop = 1
				iflip = 0
			endif
			al_num = 0
		endif
		i = al_get_row(al_num)
		if i>0
			break
		endif
	endloop
	if i>=23

		/* game over, aliens have overrun base */

		scores = scores - 10
		scoreit()
		replay()
        if command == "q"
        	return()
        endif
	endif

	if ileft
		al_put_col(al_num,al_get_col(al_num)-1)
	else
		al_put_col(al_num,al_get_col(al_num)+1)
    endif
	j = al_get_col(al_num)
	if (j==0) or (j>=(75-slow-((3*level)/2)))
		iflip = 1
    endif
	setpos(i,j)
	if flop
		ds_obj(6)
		al_put_row(al_num,al_get_row(al_num)+1)
		i = al_get_row(al_num)
		setpos(i,j)
	endif
	ds_obj(((j+(i/2))&1) + (2*(al_num/22)))

	/* check for contact with a barricade */

	if (al_get_row(al_num)>=19) and (al_get_row(al_num)<23)
		j=al_get_col(al_num)
		i = 3
		while (i>=-1) and (j+i>=0)
			barr_put(al_get_row(al_num)-19,al_get_col(al_num)+i,0)
            i = i - 1
        endwhile
	endif

	/* check for bomb release */

	if (game==1) or (game==2)
		return()
    endif
	i = al_num-11
	while i>=0
		if al_get_row(i)<>0
			return()
        endif
	    i = i - 11
	endwhile
	if (al_get_col(al_num) >= (bas_col-spread) ) and
	     (al_get_col(al_num) <  (bas_col+3+spread) ) and
	   (al_get_row(al_num)<=20)
		i = 0
		while i<bmb_max
			if bmb_get_row(i)==0
				bmb_put_row(i,al_get_row(al_num))
				bmb_put_col(i,al_get_col(al_num) + 2)
				bmb_cnt = bmb_cnt + 1
				break
			endif
            i = i + 1
		endwhile
	endif
end

/*
 * scoreit -- print current point total
 */

proc scoreit()
	setpos(0,16)
	smessage = Format(scores,"  ")
	Write(smessage)
end

/*
 * gauntlet -- challenge player to tougher game
 */

proc gauntlet()
	clr()
    Set(Attr,7)
	setpos(10,10)
	smessage = Format("Congratulations ",name_get()," ")
	Write(smessage)
	smessage = Format("- you have won at level ",level)
	level = level + 1
	Putstr(smessage)
	setpos(12,10)
	smessage = Format("Now let's see how good you are at level ",level)
	Putstr(smessage)
	Delay(50)
end

/*
 * over -- game over processing
 */

proc over()
	integer savgam

	/* display the barricades if they were invisible */

	if game >= 5
		savgam = game
		game = 3
		i = 0
		while i<=3
			setpos(i+19,0)
			j = 0
			while j<80
				if barr_get(i,j) == 1
					ds_obj(8)
				else
					 Putstr(" ")
                endif
                j = j + 1
            endwhile
		    i = i + 1
		endwhile
		game = savgam
	endif

	/* display the aliens if they were invisible */

	if game>=4
		savgam = game
		game = 3       /* remove the cloak of invisibility */
		i = 0
		while i<55
		        if al_get_row(i)<>0
			        setpos(al_get_row(i),al_get_col(i))
			        ds_obj(((al_get_col(i)+(al_get_row(i)/2))&1) + (2*(i/22)))
		        endif
                i = i + 1
		endwhile
		game = savgam
		Delay(50)
	endif
    Set(Cursor,on)
/*  exit();       */
end

/*
 * pos -- positions cursor to a display position.  Row 0 is top-of-screen
 *      row 23 is bottom-of-screen.  The leftmost column is 0; the rightmost
 *      is 79.
 */

proc setpos(integer row,integer col)
	VGotoXY(col + 1,row + 1)
end

string  proc getchar()
            string  lastkey[1] = ""

            while KeyPressed()
                lastkey = Chr(GetKey()&0ffh)
            endwhile

            return(lastkey)
        end

integer proc kbhit()
            Delay(1)
            return(KeyPressed())
        end
