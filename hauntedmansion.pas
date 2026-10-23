program OHARES3;

{$mode objfpc}{$H+}
uses
  SysUtils, StrUtils, Crt;

{------------------------------------------------------------------------------
  OHARES3 - Free Pascal conversion of John O'Hare's "Adventure 1.5" (1980)
  Commodore BASIC -> Free Pascal console application.
------------------------------------------------------------------------------}

const
  MaxNouns = 36;   // size of noun dictionary
  MaxVerbs = 32;   // size of verb dictionary
  MaxRooms = 58;   // total rooms (0..58)
  MaxObjects = 78; // total objects (0..78)
  MaxMessages = 59;// system messages (1..59)
  MaxCommands = 91;// command/action table entries
  ConsoleWidth = 80; // width of underscore separator line

{------------------------------------------------------------------------------
  GAME STATE (globals)
------------------------------------------------------------------------------}
var
  lightUnits, lightFlag, lightObject, treasureValue, treasureCount, maxScore: Integer;
  objectLimit, treasureRoom, currentRoom, limboRoom, deathRoom, adventureNumber: Integer;
  darkFlag, playerScore, ghostCount, ghostActive, ghostFlag, turnCount, hubieActive: Integer;
  verbIndex, nounIndex: Integer;               // parser results
  matchFound, matchedCommand, roomChanged, deathHappened, quitFlag, gameKilled: Integer;
  displayRoom: Boolean;                        // true when we need to clear & show a room

  objectLocation : array[0..MaxObjects] of Integer; // -1=carried, 0=limbo, else room#
  objectSize: array[0..MaxObjects] of Integer;      // weight / carry flag
  objectName: array[0..MaxObjects] of String;       // full description
  objectKeyword : array[0..MaxObjects] of String;   // 3-letter lookup key
  roomName: array[0..MaxRooms] of String;           // room descriptions
  roomExit: array[0..MaxRooms, 0..5] of Integer;    // N,S,E,W,U,D exits
  nounTable : array[0..MaxNouns] of String;        // noun dictionary
  verbTable : array[0..MaxVerbs] of String;        // verb dictionary
  messageTable : array[0..MaxMessages] of String; // system messages
  commandTable : array[1..MaxCommands] of String; // encoded command records
  synonymShort : array[1..20] of String;          // short synonym (input side)
  synonymLong : array[1..20] of String;          // long synonym (internal side)
  synonymCount : Integer;
  endCommand : String;
  eventMessage : array[1..7] of String;   // random flavor messages
  hubieMessage : array[1..3] of String;   // Hubie Marsten spirit messages
  endString : String;

  rawInput, word1, word2, verbPrefix, nounPrefix, timeString: String;

{------------------------------------------------------------------------------
  UTILITIES
------------------------------------------------------------------------------}

function ExtractNumber(const s: String; start, len: Integer): Integer;
{Convert a 2-character substring to integer; returns 0 on failure.}
var
  code, value: Integer;
  sub: String;
begin
  sub := Copy(s, start, len);
  Val(sub, value, code);
  if code <> 0 then value := 0;
  ExtractNumber := value;
end;

function RandomRange(x: Integer): Integer;
{Return random integer in 1..x.}
begin
  if x <= 0 then Exit(0);
  Result := Random(x) + 1;
end;

procedure WaitForKey;
var
  ch: Char;
begin
  Writeln;
  Write('Hit any key to continue ... ');
  ch := ReadKey;
  Writeln;
end;

{------------------------------------------------------------------------------
  DATA INITIALISATION
------------------------------------------------------------------------------}

procedure InitNouns;
begin
  nounTable[0] := 'nnn'; nounTable[1] := 'mai'; nounTable[2] := 'big'; nounTable[3] := 'spi'; nounTable[4] := 'let';
  nounTable[5] := 'doo'; nounTable[6] := 'mat'; nounTable[7] := 'but'; nounTable[8] := 'kni'; nounTable[9] := 'bot';
  nounTable[10] := 'liq'; nounTable[11] := 'des'; nounTable[12] := 'oys'; nounTable[13] := 'pap'; nounTable[14] := 'red';
  nounTable[15] := 'blu'; nounTable[16] := 'gre'; nounTable[17] := 'boo'; nounTable[18] := 'gol'; nounTable[19] := 'clo';
  nounTable[20] := 'cof'; nounTable[21] := 'pot'; nounTable[22] := 'sta'; nounTable[23] := 'lad'; nounTable[24] := 'gun';
  nounTable[25] := 'cro'; nounTable[26] := 'tru'; nounTable[27] := 'rug'; nounTable[28] := 'gob'; nounTable[29] := 'gho';
  nounTable[30] := 'tro'; nounTable[31] := 'sig'; nounTable[32] := 'fla'; nounTable[33] := 'win'; nounTable[34] := 'gam';
  nounTable[35] := 'pas';
end;

procedure InitVerbs;
begin
  verbTable[0] := 'vvv'; verbTable[1] := 'nor'; verbTable[2] := 'sou'; verbTable[3] := 'eas'; verbTable[4] := 'wes';
  verbTable[5] := 'up'; verbTable[6] := 'dow'; verbTable[7] := 'tak'; verbTable[8] := 'dro'; verbTable[9] := 'ent';
  verbTable[10] := 'inv'; verbTable[11] := 'loo'; verbTable[12] := 'sco'; verbTable[13] := 'qui'; verbTable[14] := 'hel';
  verbTable[15] := 'pus'; verbTable[16] := 'rea'; verbTable[17] := 'ope'; verbTable[18] := 'mov'; verbTable[19] := 'sho';
  verbTable[20] := 'run'; verbTable[21] := 'kil'; verbTable[22] := 'eat'; verbTable[23] := 'cli'; verbTable[24] := 'tur';
  verbTable[25] := 'on'; verbTable[26] := 'off'; verbTable[27] := 'dri'; verbTable[28] := 'cbm'; verbTable[29] := 'sav';
  verbTable[30] := 'thr'; verbTable[31] := 'sta';
end;

procedure InitRooms;
begin
  roomName[0] := '';
  roomExit[0,0] := 0; roomExit[0,1] := 0; roomExit[0,2] := 0; roomExit[0,3] := 0; roomExit[0,4] := 0; roomExit[0,5] := 0;

  roomName[1] := '*You''re on an old worn path';
  roomExit[1,0] := 6; roomExit[1,1] := 0; roomExit[1,2] := 1; roomExit[1,3] := 2; roomExit[1,4] := 0; roomExit[1,5] := 0;

  roomName[2] := '*You''re walking along an old path';
  roomExit[2,0] := 5; roomExit[2,1] := 0; roomExit[2,2] := 1; roomExit[2,3] := 3; roomExit[2,4] := 0; roomExit[2,5] := 0;

  roomName[3] := 'front of a big spooky house';
  roomExit[3,0] := 0; roomExit[3,1] := 7; roomExit[3,2] := 2; roomExit[3,3] := 4; roomExit[3,4] := 0; roomExit[3,5] := 0;

  roomName[4] := 'the haunted forest';
  roomExit[4,0] := 5; roomExit[4,1] := 4; roomExit[4,2] := 4; roomExit[4,3] := 5; roomExit[4,4] := 0; roomExit[4,5] := 0;

  roomName[5] := 'the haunted forest';
  roomExit[5,0] := 4; roomExit[5,1] := 4; roomExit[5,2] := 6; roomExit[5,3] := 4; roomExit[5,4] := 0; roomExit[5,5] := 0;

  roomName[6] := 'the haunted forest';
  roomExit[6,0] := 5; roomExit[6,1] := 4; roomExit[6,2] := 1; roomExit[6,3] := 5; roomExit[6,4] := 0; roomExit[6,5] := 0;

  roomName[7] := '*You''re on the porch of the old house';
  roomExit[7,0] := 3; roomExit[7,1] := 0; roomExit[7,2] := 0; roomExit[7,3] := 0; roomExit[7,4] := 0; roomExit[7,5] := 0;

  roomName[8] := 'an old dusty living room';
  roomExit[8,0] := 7; roomExit[8,1] := 12; roomExit[8,2] := 9; roomExit[8,3] := 0; roomExit[8,4] := 0; roomExit[8,5] := 0;

  roomName[9] := 'the dining room';
  roomExit[9,0] := 0; roomExit[9,1] := 13; roomExit[9,2] := 10; roomExit[9,3] := 8; roomExit[9,4] := 0; roomExit[9,5] := 0;

  roomName[10] := 'the kitchen';
  roomExit[10,0] := 0; roomExit[10,1] := 0; roomExit[10,2] := 11; roomExit[10,3] := 9; roomExit[10,4] := 0; roomExit[10,5] := 0;

  roomName[11] := 'a musty old pantry';
  roomExit[11,0] := 0; roomExit[11,1] := 0; roomExit[11,2] := 0; roomExit[11,3] := 10; roomExit[11,4] := 0; roomExit[11,5] := 0;

  roomName[12] := 'the family room';
  roomExit[12,0] := 8; roomExit[12,1] := 0; roomExit[12,2] := 13; roomExit[12,3] := 0; roomExit[12,4] := 0; roomExit[12,5] := 0;

  roomName[13] := 'a small alcove';
  roomExit[13,0] := 9; roomExit[13,1] := 16; roomExit[13,2] := 0; roomExit[13,3] := 12; roomExit[13,4] := 26; roomExit[13,5] := 0;

  roomName[14] := 'the study';
  roomExit[14,0] := 0; roomExit[14,1] := 17; roomExit[14,2] := 0; roomExit[14,3] := 0; roomExit[14,4] := 0; roomExit[14,5] := 0;

  roomName[15] := '*You''re at the west end of a corridor';
  roomExit[15,0] := 0; roomExit[15,1] := 18; roomExit[15,2] := 16; roomExit[15,3] := 0; roomExit[15,4] := 0; roomExit[15,5] := 0;

  roomName[16] := 'the middle of a corridor';
  roomExit[16,0] := 13; roomExit[16,1] := 19; roomExit[16,2] := 17; roomExit[16,3] := 15; roomExit[16,4] := 0; roomExit[16,5] := 0;

  roomName[17] := '*You''re at the east end of a corridor';
  roomExit[17,0] := 14; roomExit[17,1] := 20; roomExit[17,2] := 0; roomExit[17,3] := 16; roomExit[17,4] := 0; roomExit[17,5] := 0;

  roomName[18] := 'the Den';
  roomExit[18,0] := 15; roomExit[18,1] := 0; roomExit[18,2] := 0; roomExit[18,3] := 0; roomExit[18,4] := 0; roomExit[18,5] := 0;

  roomName[19] := 'the Library';
  roomExit[19,0] := 16; roomExit[19,1] := 0; roomExit[19,2] := 0; roomExit[19,3] := 0; roomExit[19,4] := 0; roomExit[19,5] := 0;

  roomName[20] := 'a Guest Room';
  roomExit[20,0] := 17; roomExit[20,1] := 0; roomExit[20,2] := 0; roomExit[20,3] := 21; roomExit[20,4] := 0; roomExit[20,5] := 0;

  roomName[21] := 'a dusty closet';
  roomExit[21,0] := 0; roomExit[21,1] := 0; roomExit[21,2] := 20; roomExit[21,3] := 0; roomExit[21,4] := 0; roomExit[21,5] := 0;

  roomName[22] := 'the trophy room';
  roomExit[22,0] := 0; roomExit[22,1] := 25; roomExit[22,2] := 0; roomExit[22,3] := 0; roomExit[22,4] := 0; roomExit[22,5] := 0;

  roomName[23] := 'an old dusty nursery';
  roomExit[23,0] := 0; roomExit[23,1] := 26; roomExit[23,2] := 0; roomExit[23,3] := 0; roomExit[23,4] := 0; roomExit[23,5] := 0;

  roomName[24] := 'a large bathroom';
  roomExit[24,0] := 0; roomExit[24,1] := 27; roomExit[24,2] := 0; roomExit[24,3] := 0; roomExit[24,4] := 0; roomExit[24,5] := 0;

  roomName[25] := '*You''re at the west end of a hallway';
  roomExit[25,0] := 22; roomExit[25,1] := 28; roomExit[25,2] := 26; roomExit[25,3] := 0; roomExit[25,4] := 0; roomExit[25,5] := 0;

  roomName[26] := 'a stairwell';
  roomExit[26,0] := 23; roomExit[26,1] := 31; roomExit[26,2] := 27; roomExit[26,3] := 25; roomExit[26,4] := 0; roomExit[26,5] := 13;

  roomName[27] := '*You''re at the east end of a hallway';
  roomExit[27,0] := 24; roomExit[27,1] := 32; roomExit[27,2] := 0; roomExit[27,3] := 26; roomExit[27,4] := 0; roomExit[27,5] := 0;

  roomName[28] := 'the master bedroom';
  roomExit[28,0] := 25; roomExit[28,1] := 0; roomExit[28,2] := 0; roomExit[28,3] := 29; roomExit[28,4] := 0; roomExit[28,5] := 0;

  roomName[29] := 'a dark, dusty closet. A ladder leads up here';
  roomExit[29,0] := 0; roomExit[29,1] := 0; roomExit[29,2] := 28; roomExit[29,3] := 0; roomExit[29,4] := 30; roomExit[29,5] := 0;

  roomName[30] := '*You''re on the ladder';
  roomExit[30,0] := 0; roomExit[30,1] := 0; roomExit[30,2] := 0; roomExit[30,3] := 0; roomExit[30,4] := 0; roomExit[30,5] := 29;

  roomName[31] := 'a yellow bedroom';
  roomExit[31,0] := 26; roomExit[31,1] := 0; roomExit[31,2] := 0; roomExit[31,3] := 0; roomExit[31,4] := 0; roomExit[31,5] := 0;

  roomName[32] := 'a white bedroom';
  roomExit[32,0] := 27; roomExit[32,1] := 0; roomExit[32,2] := 0; roomExit[32,3] := 0; roomExit[32,4] := 0; roomExit[32,5] := 0;

  roomName[33] := 'the west end of the attic';
  roomExit[33,0] := 0; roomExit[33,1] := 0; roomExit[33,2] := 34; roomExit[33,3] := 0; roomExit[33,4] := 0; roomExit[33,5] := 30;

  roomName[34] := 'the east end of the attic';
  roomExit[34,0] := 0; roomExit[34,1] := 35; roomExit[34,2] := 0; roomExit[34,3] := 33; roomExit[34,4] := 0; roomExit[34,5] := 0;

  roomName[35] := 'a dirty old storeroom';
  roomExit[35,0] := 34; roomExit[35,1] := 0; roomExit[35,2] := 0; roomExit[35,3] := 0; roomExit[35,4] := 0; roomExit[35,5] := 0;

  roomName[36] := 'the basement, there is a large open door to the south';
  roomExit[36,0] := 0; roomExit[36,1] := 40; roomExit[36,2] := 0; roomExit[36,3] := 37; roomExit[36,4] := 10; roomExit[36,5] := 0;

  roomName[37] := 'a laundry room';
  roomExit[37,0] := 0; roomExit[37,1] := 0; roomExit[37,2] := 36; roomExit[37,3] := 38; roomExit[37,4] := 0; roomExit[37,5] := 0;

  roomName[38] := 'a musty, old room in the      basement';
  roomExit[38,0] := 0; roomExit[38,1] := 39; roomExit[38,2] := 37; roomExit[38,3] := 0; roomExit[38,4] := 0; roomExit[38,5] := 0;

  roomName[39] := 'an old wine cellar';
  roomExit[39,0] := 38; roomExit[39,1] := 0; roomExit[39,2] := 0; roomExit[39,3] := 0; roomExit[39,4] := 0; roomExit[39,5] := 0;

  roomName[40] := 'a chilly, damp room';
  roomExit[40,0] := 36; roomExit[40,1] := 0; roomExit[40,2] := 0; roomExit[40,3] := 0; roomExit[40,4] := 0; roomExit[40,5] := 0;

  roomName[41] := 'a secret underground cavern';
  roomExit[41,0] := 0; roomExit[41,1] := 42; roomExit[41,2] := 0; roomExit[41,3] := 0; roomExit[41,4] := 40; roomExit[41,5] := 0;

  roomName[42] := 'a narrow passage';
  roomExit[42,0] := 41; roomExit[42,1] := 0; roomExit[42,2] := 43; roomExit[42,3] := 0; roomExit[42,4] := 0; roomExit[42,5] := 0;

  roomName[43] := 'a drafty chamber';
  roomExit[43,0] := 0; roomExit[43,1] := 0; roomExit[43,2] := 44; roomExit[43,3] := 42; roomExit[43,4] := 0; roomExit[43,5] := 0;

  roomName[44] := 'a large circular chamber';
  roomExit[44,0] := 45; roomExit[44,1] := 0; roomExit[44,2] := 46; roomExit[44,3] := 43; roomExit[44,4] := 0; roomExit[44,5] := 0;

  roomName[45] := 'a splendid chamber 30 feet    high';
  roomExit[45,0] := 47; roomExit[45,1] := 44; roomExit[45,2] := 0; roomExit[45,3] := 0; roomExit[45,4] := 0; roomExit[45,5] := 0;

  roomName[46] := 'a roughly carved room, a pit  leads down';
  roomExit[46,0] := 0; roomExit[46,1] := 52; roomExit[46,2] := 0; roomExit[46,3] := 44; roomExit[46,4] := 0; roomExit[46,5] := 53;

  roomName[47] := '*You''re at a junction of three passages';
  roomExit[47,0] := 0; roomExit[47,1] := 45; roomExit[47,2] := 48; roomExit[47,3] := 56; roomExit[47,4] := 0; roomExit[47,5] := 0;

  roomName[48] := 'a dusty passage';
  roomExit[48,0] := 0; roomExit[48,1] := 0; roomExit[48,2] := 49; roomExit[48,3] := 47; roomExit[48,4] := 0; roomExit[48,5] := 0;

  roomName[49] := 'an old broken passage';
  roomExit[49,0] := 0; roomExit[49,1] := 0; roomExit[49,2] := 50; roomExit[49,3] := 48; roomExit[49,4] := 0; roomExit[49,5] := 0;

  roomName[50] := '*You''re at a turn in the passage';
  roomExit[50,0] := 0; roomExit[50,1] := 51; roomExit[50,2] := 0; roomExit[50,3] := 49; roomExit[50,4] := 0; roomExit[50,5] := 0;

  roomName[51] := 'a TORTURE CHAMBER';
  roomExit[51,0] := 50; roomExit[51,1] := 0; roomExit[51,2] := 0; roomExit[51,3] := 0; roomExit[51,4] := 0; roomExit[51,5] := 0;

  roomName[52] := 'a cold damp room';
  roomExit[52,0] := 46; roomExit[52,1] := 0; roomExit[52,2] := 0; roomExit[52,3] := 0; roomExit[52,4] := 0; roomExit[52,5] := 0;

  roomName[53] := 'a pit';
  roomExit[53,0] := 0; roomExit[53,1] := 0; roomExit[53,2] := 0; roomExit[53,3] := 0; roomExit[53,4] := 0; roomExit[53,5] := 54;

  roomName[54] := 'a pit';
  roomExit[54,0] := 0; roomExit[54,1] := 0; roomExit[54,2] := 0; roomExit[54,3] := 0; roomExit[54,4] := 0; roomExit[54,5] := 55;

  roomName[55] := 'a pit.  There are no exits';
  roomExit[55,0] := 0; roomExit[55,1] := 0; roomExit[55,2] := 0; roomExit[55,3] := 0; roomExit[55,4] := 0; roomExit[55,5] := 0;

  roomName[56] := 'a dead end passage';
  roomExit[56,0] := 0; roomExit[56,1] := 0; roomExit[56,2] := 47; roomExit[56,3] := 0; roomExit[56,4] := 0; roomExit[56,5] := 0;

  roomName[57] := ' a misty room with strange    looking exits'; // LIMBO
  roomExit[57,0] := 1; roomExit[57,1] := 58; roomExit[57,2] := 58; roomExit[57,3] := 58; roomExit[57,4] := 5; roomExit[57,5] := 58;

  roomName[58] := ' H E L L '; // DEATH
  roomExit[58,0] := 0; roomExit[58,1] := 0; roomExit[58,2] := 0; roomExit[58,3] := 0; roomExit[58,4] := 0; roomExit[58,5] := 0;
end;

procedure InitObjects;
{Initialize object table.  ob% (3rd BASIC value) = starting room; ob (4th) = size.}
begin
  objectName[0] := ''; objectKeyword[0] := ''; objectSize[0] := 0; objectLocation[0] := 0;

  objectName[1] := 'MAILBOX (name on it:  Hubie Marsten)'; objectKeyword[1] := 'mai'; objectSize[1] := 1; objectLocation[1] := 3;
  objectName[2] := 'ring of keys'; objectKeyword[2] := 'key'; objectSize[2] := 0; objectLocation[2] := 0;
  objectName[3] := 'old letter'; objectKeyword[3] := 'let'; objectSize[3] := 0; objectLocation[3] := 0;
  objectName[4] := 'LARGE PADLOCKED DOOR'; objectKeyword[4] := 'doo'; objectSize[4] := 1; objectLocation[4] := 7;
  objectName[5] := 'OPEN DOOR'; objectKeyword[5] := 'doo'; objectSize[5] := 1; objectLocation[5] := 0;
  objectName[6] := 'doormat'; objectKeyword[6] := 'mat'; objectSize[6] := 0; objectLocation[6] := 7;
  objectName[7] := 'BUTTON BY DOOR (doorbell?)'; objectKeyword[7] := 'but'; objectSize[7] := 1; objectLocation[7] := 7;
  objectName[8] := 'SIGN - LEAVE TREASURE HERE SAYS SCORE'; objectKeyword[8] := 'sig'; objectSize[8] := 1; objectLocation[8] := 7;
  objectName[9] := 'FURNITURE'; objectKeyword[9] := 'fur'; objectSize[9] := 1; objectLocation[9] := 8;
  objectName[10] := 'TABLE & CHAIRS'; objectKeyword[10] := 'tab'; objectSize[10] := 1; objectLocation[10] := 9;
  objectName[11] := '*silver candlesticks*'; objectKeyword[11] := 'can'; objectSize[11] := 0; objectLocation[11] := 9;
  objectName[12] := '*silver knife*'; objectKeyword[12] := 'kni'; objectSize[12] := 0; objectLocation[12] := 10;
  objectName[13] := 'pool of blood'; objectKeyword[13] := 'blo'; objectSize[13] := 1; objectLocation[13] := 10;
  objectName[14] := 'BIG MAC'; objectKeyword[14] := 'big'; objectSize[14] := 0; objectLocation[14] := 10;
  objectName[15] := 'vial of strange liquid'; objectKeyword[15] := 'via'; objectSize[15] := 0; objectLocation[15] := 11;
  objectName[16] := '*wallet full of $100s*'; objectKeyword[16] := 'wal'; objectSize[16] := 0; objectLocation[16] := 12;
  objectName[17] := 'DESK'; objectKeyword[17] := 'des'; objectSize[17] := 1; objectLocation[17] := 14;
  objectName[18] := 'slip of paper'; objectKeyword[18] := 'pap'; objectSize[18] := 0; objectLocation[18] := 0;
  objectName[19] := 'magic gun'; objectKeyword[19] := 'gun'; objectSize[19] := 0; objectLocation[19] := 0;
  objectName[20] := '*gold watch*'; objectKeyword[20] := 'wat'; objectSize[20] := 0; objectLocation[20] := 18;
  objectName[21] := '*rare painting*'; objectKeyword[21] := 'pai'; objectSize[21] := 0; objectLocation[21] := 18;
  objectName[22] := 'red book'; objectKeyword[22] := 'red'; objectSize[22] := 0; objectLocation[22] := 19;
  objectName[23] := 'blue book'; objectKeyword[23] := 'blu'; objectSize[23] := 0; objectLocation[23] := 19;
  objectName[24] := 'green book'; objectKeyword[24] := 'gre'; objectSize[24] := 0; objectLocation[24] := 19;
  objectName[25] := '*gold book*'; objectKeyword[25] := 'gol'; objectSize[25] := 0; objectLocation[25] := 0;
  objectName[26] := 'CLOSET'; objectKeyword[26] := 'xxx'; objectSize[26] := 1; objectLocation[26] := 20;
  objectName[27] := 'bed'; objectKeyword[27] := 'bed'; objectSize[27] := 1; objectLocation[27] := 20;
  objectName[28] := '*oriental rug*'; objectKeyword[28] := 'rug'; objectSize[28] := 0; objectLocation[28] := 20;
  objectName[29] := 'cloths'; objectKeyword[29] := 'clo'; objectSize[29] := 1; objectLocation[29] := 21;
  objectName[30] := '*mink*'; objectKeyword[30] := 'min'; objectSize[30] := 0; objectLocation[30] := 21;
  objectName[31] := '*gold medal*'; objectKeyword[31] := 'med'; objectSize[31] := 0; objectLocation[31] := 22;
  objectName[32] := 'crib'; objectKeyword[32] := 'cri'; objectSize[32] := 1; objectLocation[32] := 23;
  objectName[33] := '* $1000 savings bond *'; objectKeyword[33] := 'bon'; objectSize[33] := 0; objectLocation[33] := 23;
  objectName[34] := 'toilet'; objectKeyword[34] := 'toi'; objectSize[34] := 1; objectLocation[34] := 24;
  objectName[35] := 'sink'; objectKeyword[35] := 'sin'; objectSize[35] := 1; objectLocation[35] := 24;
  objectName[36] := 'a bubbling potion'; objectKeyword[36] := 'pot'; objectSize[36] := 0; objectLocation[36] := 24;
  objectName[37] := 'stairs going down'; objectKeyword[37] := 'sta'; objectSize[37] := 1; objectLocation[37] := 26;
  objectName[38] := 'wooden cross'; objectKeyword[38] := 'cro'; objectSize[38] := 0; objectLocation[38] := 26;
  objectName[39] := 'CLOSET'; objectKeyword[39] := 'xxx'; objectSize[39] := 1; objectLocation[39] := 28;
  objectName[40] := '*pearl necklace*'; objectKeyword[40] := 'nec'; objectSize[40] := 0; objectLocation[40] := 28;
  objectName[41] := 'bed'; objectKeyword[41] := 'bed'; objectSize[41] := 1; objectLocation[41] := 28;
  objectName[42] := '*velvet pillow*'; objectKeyword[42] := 'pil'; objectSize[42] := 0; objectLocation[42] := 28;
  objectName[43] := 'ladder'; objectKeyword[43] := 'lad'; objectSize[43] := 1; objectLocation[43] := 29;
  objectName[44] := 'furniture'; objectKeyword[44] := 'fur'; objectSize[44] := 1; objectLocation[44] := 31;
  objectName[45] := '*Commodore PET*'; objectKeyword[45] := 'pet'; objectSize[45] := 0; objectLocation[45] := 31;
  objectName[46] := 'furniture'; objectKeyword[46] := 'fur'; objectSize[46] := 1; objectLocation[46] := 32;
  objectName[47] := 'cobwebs'; objectKeyword[47] := 'cob'; objectSize[47] := 1; objectLocation[47] := 33;
  objectName[48] := '*rare family jewels*'; objectKeyword[48] := 'jew'; objectSize[48] := 0; objectLocation[48] := 34;
  objectName[49] := 'A body hanging from a noose (Hubie?)'; objectKeyword[49] := 'bod'; objectSize[49] := 1; objectLocation[49] := 35;
  objectName[50] := 'old trunk'; objectKeyword[50] := 'tru'; objectSize[50] := 1; objectLocation[50] := 35;
  objectName[51] := '*rare coins*'; objectKeyword[51] := 'coi'; objectSize[51] := 0; objectLocation[51] := 0;
  objectName[52] := '*bottle of rare imported wine*'; objectKeyword[52] := 'win'; objectSize[52] := 0; objectLocation[52] := 39;
  objectName[53] := 'An old wooden Coffin'; objectKeyword[53] := 'cof'; objectSize[53] := 1; objectLocation[53] := 40;
  objectName[54] := 'A dangerous GOBLIN'; objectKeyword[54] := 'gob'; objectSize[54] := 2; objectLocation[54] := 45;
  objectName[55] := 'A mean TROLL'; objectKeyword[55] := 'tro'; objectSize[55] := 2; objectLocation[55] := 43;
  objectName[56] := 'a torture rack'; objectKeyword[56] := 'rac'; objectSize[56] := 1; objectLocation[56] := 51;
  objectName[57] := '*gold death mask*'; objectKeyword[57] := 'mas'; objectSize[57] := 0; objectLocation[57] := 51;
  objectName[58] := 'GIANT OYSTER'; objectKeyword[58] := 'oys'; objectSize[58] := 1; objectLocation[58] := 52;
  objectName[59] := '*sack of diamonds*'; objectKeyword[59] := 'dia'; objectSize[59] := 0; objectLocation[59] := 55;
  objectName[60] := '*large ruby*'; objectKeyword[60] := 'rub'; objectSize[60] := 0; objectLocation[60] := 56;
  objectName[61] := 'A GHOST'; objectKeyword[61] := 'gho'; objectSize[61] := 2; objectLocation[61] := 0;
  objectName[62] := 'flashlight(on)'; objectKeyword[62] := 'fla'; objectSize[62] := 0; objectLocation[62] := 0;
  objectName[63] := 'flashlight(off)'; objectKeyword[63] := 'fla'; objectSize[63] := 0; objectLocation[63] := 11;
  objectName[64] := 'large rug'; objectKeyword[64] := 'xxx'; objectSize[64] := 1; objectLocation[64] := 10;
  objectName[65] := 'locked trapdoor'; objectKeyword[65] := 'tra'; objectSize[65] := 1; objectLocation[65] := 0;
  objectName[66] := 'open trapdoor'; objectKeyword[66] := 'tra'; objectSize[66] := 1; objectLocation[66] := 0;
  objectName[67] := 'locked trapdoor'; objectKeyword[67] := 'tra'; objectSize[67] := 1; objectLocation[67] := 30;
  objectName[68] := 'open trapdoor'; objectKeyword[68] := 'tra'; objectSize[68] := 1; objectLocation[68] := 0;
  objectName[69] := '*giant pearl*'; objectKeyword[69] := 'pea'; objectSize[69] := 0; objectLocation[69] := 0;
  objectName[70] := 'stairs going up'; objectKeyword[70] := 'sta'; objectSize[70] := 1; objectLocation[70] := 13;
  objectName[71] := 'cobwebs'; objectKeyword[71] := 'cob'; objectSize[71] := 1; objectLocation[71] := 8;
  objectName[72] := 'SIGN SAYS - YOU SHALL DIE....'; objectKeyword[72] := 'sig'; objectSize[72] := 1; objectLocation[72] := 5;
  objectName[73] := '-Barlow the Vampire-'; objectKeyword[73] := 'vam'; objectSize[73] := 2; objectLocation[73] := 0;
  objectName[74] := 'The spirit of Hubie Marsten'; objectKeyword[74] := 'spi'; objectSize[74] := 1; objectLocation[74] := 0;
  objectName[75] := 'empty vial'; objectKeyword[75] := 'via'; objectSize[75] := 0; objectLocation[75] := 0;
  objectName[76] := 'sweet smelling broken glass'; objectKeyword[76] := 'gla'; objectSize[76] := 0; objectLocation[76] := 0;
  objectName[77] := 'PASSAGE'; objectKeyword[77] := 'pas'; objectSize[77] := 1; objectLocation[77] := 0;
  objectName[78] := 'empty bottle'; objectKeyword[78] := 'bot'; objectSize[78] := 0; objectLocation[78] := 0;
end;

procedure InitMessages;
begin
  messageTable[1] := 'nothing happens';
  messageTable[2] := 'how should I know what to do';
  messageTable[3] := 'I''M DEAD';
  messageTable[4] := 'a couple things fell out';
  messageTable[5] := 'something fell out';
  messageTable[6] := 'the trapdoor creaks open';
  messageTable[7] := 'the door creaks open';
  messageTable[8] := 'It says: those who enter may not leave here''s a hint they may need';
  messageTable[9] := 'If something is too heavy to take, try to move it';
  messageTable[10] := 'OK, I moved it';
  messageTable[11] := 'OK, weird laughing comes from the house';
  messageTable[12] := 'the troll drinks the potion and turns into a frog, the frog hops away';
  messageTable[13] := 'you got him.  The goblin and disappears in a cloud of black smoke';
  messageTable[14] := 'Barlow turns to dust and blows away';
  messageTable[15] := 'The ghost vaporizes';
  messageTable[16] := 'It''s poison.  I''m dead!';
  messageTable[17] := 'Everything changes and....';
  messageTable[18] := 'BANG BANG BANG';
  messageTable[19] := 'you got him';
  messageTable[20] := 'you missed';
  messageTable[21] := 'it says - Hubie is harmless';
  messageTable[22] := 'It says:';
  messageTable[23] := 'This book is a treasure';
  messageTable[24] := 'The bottle of wine drops with a CRASH!';
  messageTable[25] := 'It''s empty';
  messageTable[26] := 'some treasures may be weapons           shoot goblin-troll potion!';
  messageTable[27] := 'say CBM';
  messageTable[28] := 'Kill a Vampire with *silver*            when trapped, take a drink';
  messageTable[29] := 'indentify book by color';
  messageTable[30] := 'I don''t have it';
  messageTable[31] := 'Where?!?';
  messageTable[32] := 'The BLUE book turns into a *gold* book';
  messageTable[33] := 'thanks I was hungery';
  messageTable[34] := 'the flashlight is on';
  messageTable[35] := 'the flashlight is off';
  messageTable[36] := 'I can''t move that!';
  messageTable[37] := 'there was something under it';
  messageTable[38] := 'OK,';
  messageTable[39] := 'It''s locked';
  messageTable[40] := 'It''s to heavy';
  messageTable[41] := 'I need a key';
  messageTable[42] := 'The oyster opens up to eat the BIG MAC and a pearl rolls out!';
  messageTable[43] := 'The bottle lands softly on the pillow';
  messageTable[44] := 'A voice booms out.....PLEASE LEAVE IT ALONE!';
  messageTable[45] := 'The lid of the Coffin rises and Barlow the vampire jumps out!!!';
  messageTable[46] := 'I don''t see it here';
  messageTable[47] := 'HOW?!?';
  messageTable[48] := 'I have nothing to read';
  messageTable[49] := 'NOTWELCOME';
  messageTable[50] := 'closets aren''t closed';
  messageTable[51] := 'I have nothing to eat';
  messageTable[52] := 'I have nothing to drink';
  messageTable[53] := 'I don''t have a gun';
  messageTable[54] := 'I don''t have a knife';
  messageTable[55] := 'Barlow stops me!';
  messageTable[56] := 'There is nothing to attack here';
  messageTable[57] := 'The bullets bounce off the shell!';
  messageTable[58] := 'He only eats big macs and I don''t have one';
  messageTable[59] := 'hic hic, burp.  Boy was that good!';
end;

procedure InitCommands;
var
  i: Integer;
begin
  for i := 1 to MaxCommands do commandTable[i] := '';
  commandTable[1]  := '1000000000000000100000000000000000';
  commandTable[2]  := '1100000000000000110000000000000000';
  commandTable[3]  := '1200000000000000120000000000000000';
  commandTable[4]  := '1300000000000000130000000000000000';
  commandTable[5]  := '0712055800000000014000000000000000';
  commandTable[6]  := '0720055300000000014000000000000000';
  commandTable[7]  := '0726055000000000014000000000000000';
  commandTable[8]  := '0717000000000000012900000000000000';
  commandTable[9]  := '0731000000000000014400000000000000';
  commandTable[10] := '0727056400000000014000000000000000';
  commandTable[11] := '0732056300000000146300000000000000';
  commandTable[12] := '0802055803690114014200046900031400';
  commandTable[13] := '0802055800000000015800000000000000';
  commandTable[14] := '0821055501360000011200035500033600';
  commandTable[15] := '0832016300000000156300000000000000';
  commandTable[16] := '0817000000000000012900000000000000';
  commandTable[17] := '0905050400000000013900000000000000';
  commandTable[18] := '0833015205420000014300155200000000';
  commandTable[19] := '0833015200000000012400155200025276';
  commandTable[20] := '0700000000000000070000000000000000';
  commandTable[21] := '0800000000000000080000000000000000';
  commandTable[22] := '0905050500000000050800000000000000';
  commandTable[23] := '0905056600000000053600000000000000';
  commandTable[24] := '0905056800000000053300000000000000';
  commandTable[25] := '0919052600000000052100000000000000';
  commandTable[26] := '0919053900000000052900000000000000';
  commandTable[27] := '0935057700000000054100000000000000';
  commandTable[28] := '1400000000000000010200000000000000';
  commandTable[29] := '1507050700000000011100000000000000';
  commandTable[30] := '1604010300000000010800010900000000';
  commandTable[31] := '1606050600000000012200014900000000';
  commandTable[32] := '1613011800000000012100000000000000';
  commandTable[33] := '1617000000000000012900000000000000';
  commandTable[34] := '1614012200000000012200012600000000';
  commandTable[35] := '1615012300000000012200012700000000';
  commandTable[36] := '1616012400000000012200012800000000';
  commandTable[37] := '1618012500000000012200012300000000';
  commandTable[38] := '1600000000000000014800000000000000';
  commandTable[39] := '1720037305530000012500014500047300';
  commandTable[40] := '1720055300000000012500000000000000';
  commandTable[41] := '1705050401020000010700020405170108';
  commandTable[42] := '1701050103020303010400040300040200';
  commandTable[43] := '1701050100000000012500000000000000';
  commandTable[44] := '1705056501020000010600026566170536';
  commandTable[45] := '1705056500000000014100000000000000';
  commandTable[46] := '1705050400000000014100000000000000';
  commandTable[47] := '1705056701020000010600026768170433';
  commandTable[48] := '1705056700000000014100000000000000';
  commandTable[49] := '1719000000000000015000000000000000';
  commandTable[50] := '1711051703180319010400041800041900';
  commandTable[51] := '1726055003510000010500045100000000';
  commandTable[52] := '1726055000000000012500000000000000';
  commandTable[53] := '1711051700000000012500000000000000';
  commandTable[54] := '1820057305530000015500000000000000';
  commandTable[55] := '1820037305530000014500015500047300';
  commandTable[56] := '1827056403650366011000013700046500';
  commandTable[57] := '1820055303770000011000013700047700';
  commandTable[58] := '1812000000000000013600000000000000';
  commandTable[59] := '1900056101190000011800180000000000';
  commandTable[60] := '1900057401190000011800010100000000';
  commandTable[61] := '1900055401190000011800011300035400';
  commandTable[62] := '1900055501190000011800010100000000';
  commandTable[63] := '1900055801190000015700000000000000';
  commandTable[64] := '1900057301190000011800010100000000';
  commandTable[65] := '1900011900000000015600000000000000';
  commandTable[66] := '1900000000000000015300000000000000';
  commandTable[67] := '2000000000000000013100000000000000';
  commandTable[68] := '2100000000000000014700000000000000';
  commandTable[69] := '2200011400000000013300031400000000';
  commandTable[70] := '2200000000000000015100000000000000';
  commandTable[71] := '2323054300000000053000000000000000';
  commandTable[72] := '2400016200000000013500026263770000';
  commandTable[73] := '2400016300000000013400026263770000';
  commandTable[74] := '2500016300000000013400026263770000';
  commandTable[75] := '2600016200000000013500026263770000';
  commandTable[76] := '2710011502550000011700021575050600';
  commandTable[77] := '2710011500000000011700021575050800';
  commandTable[78] := '2733015200000000015900025278000000';
  commandTable[79] := '2721013600000000011600033600060000';
  commandTable[80] := '2721000000000000013000000000000000';
  commandTable[81] := '2710000000000000013000000000000000';
  commandTable[82] := '2700000000000000015200000000000000';
  commandTable[83] := '2800012300000000013200022325000000';
  commandTable[84] := '2800000000000000010100000000000000';
  commandTable[85] := '2934000000000000160000000000000000';
  commandTable[86] := '3008057301120000011400097399041200';
  commandTable[87] := '3008011200000000010100041200000000';
  commandTable[88] := '3008000000000000015400000000000000';
  commandTable[89] := '3100057301120000011400097399000000';
  commandTable[90] := '3100011200000000010100000000000000';
  commandTable[91] := '3100000000000000015400000000000000';
end;

procedure InitSynonyms;
{Map short player input to 3-letter internal codes.  'use' was mapped to
'shoot' in the original; removed so "use key" does not trigger combat.}
begin
  synonymCount := 13;
  synonymShort[1] := 'n';  synonymLong[1] := 'nor';
  synonymShort[2] := 's';  synonymLong[2] := 'sou';
  synonymShort[3] := 'e';  synonymLong[3] := 'eas';
  synonymShort[4] := 'w';  synonymLong[4] := 'wes';
  synonymShort[5] := 'u';  synonymLong[5] := 'up';
  synonymShort[6] := 'd';  synonymLong[6] := 'dow';
  synonymShort[7] := 'get'; synonymLong[7] := 'tak';
  synonymShort[9] := 'sea'; synonymLong[9] := 'ope';
  synonymShort[10] := 'att'; synonymLong[10] := 'kil';
  synonymShort[11] := 'fir'; synonymLong[11] := 'sho';
  synonymShort[12] := 'fee'; synonymLong[12] := 'dro';
  synonymShort[13] := 'giv'; synonymLong[13] := 'dro';
  endCommand := 'end';
end;

procedure InitEvents;
begin
  eventMessage[1] := 'A black cat runs by';
  eventMessage[2] := 'I heard a funny noise';
  eventMessage[3] := 'I think I hear footsteps';
  eventMessage[4] := 'Was that a scream I heard ?';
  eventMessage[5] := 'I feel a chill';
  eventMessage[6] := 'A spider runs by';
  eventMessage[7] := 'I think I heard a door slam';
  hubieMessage[1] := 'Who dares to enter this house';
  hubieMessage[2] := 'You shall die...';
  hubieMessage[3] := 'Get out, get out before it''s too late';
  endString := 'the end';
end;

{------------------------------------------------------------------------------
  GAME LOGIC
------------------------------------------------------------------------------}

procedure CheckLight;
{Manage flashlight battery and darkness.}
begin
  if (lightUnits < 50) and (lightFlag = 2) and (objectLocation[lightObject] <> 0) then
  begin
    Writeln('Your flashlight is getting dim!');
    lightFlag := 1;
  end;

  if (lightUnits < 38) and (lightFlag = 1) and (objectLocation[lightObject] <> 0) then
  begin
    Writeln('Your flashlight is getting dimmer!!');
    lightFlag := 0;
  end;

  if (lightUnits < 25) and (lightUnits > 0) and (objectLocation[lightObject] <> 0) then
  begin
    Writeln;
    Writeln('LIGHT RUNS OUT IN ', lightUnits, ' TURNS!');
  end;

  if (lightUnits = 0) and (lightFlag = 0) then
  begin
    Writeln('LIGHT HAS RUN OUT!!!');
    lightFlag := -1;
    objectLocation[lightObject] := 0;
  end;
end;

procedure ProcessRandomEvents;
{Random monster / ghost encounters based on turn count and room.}
begin
  if (objectLocation[54] = currentRoom) or (objectLocation[55] = currentRoom) or (objectLocation[73] = currentRoom) or (objectLocation[74] = currentRoom) then
  begin
    objectLocation[61] := 0;
    Exit;
  end;

  if (currentRoom < 8) or (currentRoom = limboRoom) or (currentRoom = deathRoom) or (turnCount < 35) then Exit;

  if ghostCount = 0 then Exit;

  if ghostActive = 1 then
  begin
    objectLocation[61] := currentRoom;
    Writeln('There is a threatening little ghost in the room with you!');
    ghostFlag := 1 - ghostFlag;
    if ghostFlag <> 0 then Exit;
    Writeln('The ghost attacks!');
    if RandomRange(6) = 2 then
    begin
      Writeln('It got you!');
      currentRoom := limboRoom;
      ghostActive := 0;
      gameKilled := 1;
      Exit;
    end;
    Writeln('It missed!');
  end
  else if RandomRange(32) = 7 then
  begin
    ghostActive := 1;
  end
  else
  begin
    objectLocation[61] := 0;
  end;
end;

procedure AttackGhost;
{Player attacks ghost; success removes it from game.}
begin
  if RandomRange(5) > 2 then
  begin
    Writeln('You missed!');
    Exit;
  end;

  Writeln('You got him!');
  Writeln('The ghost dissapears in a white mist!');
  ghostCount := ghostCount - 1;
  ghostActive := 0;
  ghostFlag := 0;
  objectLocation[61] := 0;
end;

procedure DescribeRoomEvents;
{Ambient messages, Hubie spirit, and monster attacks each turn.}
begin
  if currentRoom = 27 then
    Writeln('A clock shows the time: ', timeString);

  if hubieActive = 1 then
  begin
    Writeln('The spirit of Hubie Marsten appears and says:');
    Writeln(hubieMessage[RandomRange(3)], '.');
    objectLocation[74] := currentRoom;
    hubieActive := 0;
  end;

  if (RandomRange(5) = 4) and (currentRoom > 6) then
    Writeln(eventMessage[RandomRange(7)], '.');

  if (currentRoom > 3) and (currentRoom < 7) and (RandomRange(4) = 2) then
    Writeln('The trees seem to be alive!');

  if (currentRoom > 32) and (currentRoom < 36) and (objectLocation[74] <> currentRoom) then
    if RandomRange(3) = 2 then hubieActive := 1;

  if (objectLocation[74] = currentRoom) and (RandomRange(3) = 2) then
  begin
    Writeln('The spirit vanished??');
    objectLocation[74] := 0;
    hubieActive := 0;
  end;

  if (objectLocation[54] = currentRoom) and (RandomRange(3) = 2) then
  begin
    Writeln('The goblin attack with an axe in hand!');
    if RandomRange(6) = 4 then
    begin
      Writeln('CRUNCH!!     He gets you!');
      currentRoom := limboRoom;
      gameKilled := 1;
      Exit;
    end;
    Writeln('WHOOSH!     He misses!');
  end;

  if (objectLocation[55] = currentRoom) and (RandomRange(3) = 2) then
  begin
    Writeln('The troll attacks!');
    if RandomRange(7) = 6 then
    begin
      Writeln('He smashes your skull!');
      currentRoom := limboRoom;
      gameKilled := 1;
      Exit;
    end;
    Writeln('He missed!');
  end;

  if (objectLocation[73] = currentRoom) and (RandomRange(3) = 2) then
  begin
    Writeln('Barlow attacks!');
    if objectLocation[38] = -1 then
    begin
      Writeln('He sees your cross and backs off!');
      Exit;
    end;
    if RandomRange(4) = 3 then
    begin
      Writeln('He got you!!');
      currentRoom := limboRoom;
      gameKilled := 1;
      Exit;
    end;
    Writeln('He missed!');
  end;
end;

procedure TakeObject(obj: Integer);
{Pick up an object if it is in the current room and the player can carry it.}
var
  carryIndex, carriedCount: Integer;
begin
  if objectSize[obj] = 1 then
  begin
    Writeln('IT''S BEYOND MY POWER TO DO THAT!');
    Exit;
  end;

  if objectSize[obj] > 1 then
  begin
    Writeln('Don''t be stupid!');
    Exit;
  end;

  if objectLocation[obj] = -1 then
  begin
    Writeln('I''m already carrying it.');
    Exit;
  end;

  if objectLocation[obj] <> currentRoom then
  begin
    Writeln('I DON''T SEE IT HERE!');
    Exit;
  end;

  carriedCount := 0;
  for carryIndex := 1 to MaxObjects do
    if objectLocation[carryIndex] = -1 then
       Inc(carriedCount);

  if carriedCount + 1 > objectLimit then
  begin
    Writeln('I''VE TOO MUCH TO CARRY');
    Exit;
  end;

  Writeln('ok,');
  objectLocation[obj] := -1;
end;

procedure DropTreasure;
{Drop all carried treasure in the current room.}
var
  treasureIndex, treasurePlaced: Integer;
begin
  treasurePlaced := 0;
  for treasureIndex := 1 to MaxObjects do
  begin
    if Copy(objectName[treasureIndex], 1, 1) <> '*' then Continue;
    if (treasureIndex = 52) and (objectLocation[treasureIndex] = -1) and (objectLocation[42] <> currentRoom) then
    begin
      Writeln(messageTable[24]);
      objectLocation[52] := 0;
      objectLocation[76] := currentRoom;
      Continue;
    end;

    if (treasureIndex = 52) and (objectLocation[treasureIndex] = -1) then
    begin
      Writeln(messageTable[43]);
      objectLocation[treasureIndex] := currentRoom;
      Continue;
    end;

    if objectLocation[treasureIndex] = -1 then
    begin
      objectLocation[treasureIndex] := currentRoom;
      Writeln('dropped: ', objectName[treasureIndex]);
      treasurePlaced := 1;
    end;
  end;

  if treasurePlaced = 0 then Writeln('You have no treasure to drop.');
end;

procedure DropObject(obj: Integer);
{Drop a specific carried object in the current room.}
begin
  if objectLocation[obj] = -1 then
  begin
    objectLocation[obj] := currentRoom;
    Writeln('ok,');
  end
  else
    Writeln('I''M NOT CARRYING IT!');
end;

procedure ShowInventory;
{List everything the player is carrying (location = -1).}
var
  itemIndex, carriedFlag: Integer;
begin
  carriedFlag := 0;
  Writeln('I''M CARRYING:');
  for itemIndex := 1 to MaxObjects do
  begin
    if objectLocation[itemIndex] <> -1 then Continue;
    carriedFlag := 1;
    Writeln(objectName[itemIndex], '.  ');
  end;

  if carriedFlag <> 0 then Writeln;
  if carriedFlag = 0 then Writeln('nothing');
end;

procedure AttemptMove(direction: Integer);
{Try to move in one of the 6 directions.  0=N,1=S,2=E,3=W,4=U,5=D.}
begin
  if (roomExit[currentRoom, direction] = 0) and (darkFlag = 0) then
  begin
    Writeln('I CAN''T GO IN THAT DIRECTION.');
    Exit;
  end;

  if (roomExit[currentRoom, direction] = 0) and (darkFlag = 1) then
  begin
    Writeln('I FELL DOWN AND BROKE MY NECK!!');
    currentRoom := limboRoom;
    playerScore := playerScore - 5;
    Exit;
  end;

  if (objectLocation[54] = currentRoom) and (direction = 1) then
  begin
    Writeln('The goblin won''t let me by!');
    Exit;
  end;

  if (objectLocation[55] = currentRoom) and (direction = 3) then
  begin
    Writeln('The troll is blocking my way!');
    Exit;
  end;

  currentRoom := roomExit[currentRoom, direction];
  roomChanged := 1;
end;

procedure CalculateScore;
var
  i, finalScore: Integer;
begin
  finalScore := 0;
  for i := 1 to MaxObjects do
  begin
    if (Copy(objectName[i], Length(objectName[i]), 1) = '*') and (objectLocation[i] = treasureRoom) then
      finalScore := finalScore + treasureValue;
  end;

  if quitFlag = 1 then playerScore := playerScore - 4;

  if playerScore < 0 then playerScore := 0;

  finalScore := finalScore + playerScore;

  Writeln('YOUR SCORE IS ', finalScore, ' OUT OF A POSSIBLE ', maxScore);

  { Always show detailed score when quitting; otherwise only when all treasures found }
  if (quitFlag <> 1) and (finalScore - playerScore <> 300) then Exit;

  Writeln('You scored ', finalScore, ' points.');
  Writeln('There were ', maxScore, ' points possible.');

  if finalScore < 1 then
  begin
    Writeln('You must have nothing but space between your ears!');
    Exit;
  end
  else if finalScore < 51 then
  begin
    Writeln('You are obviously a rank amateur.');
    Exit;
  end
  else if finalScore < 75 then
  begin
    Writeln('Your score qualifies you as a novice class adventurer.');
    Exit;
  end
  else if finalScore < 125 then
  begin
    Writeln('You''ve achieved the rating: Experienced Adventurer');
    Exit;
  end
  else if finalScore < 175 then
  begin
    Writeln('You have reached the ''junior master'' status.');
    Exit;
  end
  else if finalScore < 225 then
  begin
    Writeln('Your score puts you in MASTER ADVENTURER class -D-');
    Exit;
  end
  else if finalScore < 295 then
  begin
    Writeln('Your score puts you in MASTER ADVENTURER class -C-');
    Exit;
  end
  else if finalScore < 345 then
  begin
    Writeln('Your score puts you in MASTER ADVENTURER class -B-');
    Exit;
  end
  else if finalScore < 350 then
  begin
    Writeln('Your score puts you in MASTER ADVENTURER class -A-');
    Exit;
  end
  else if finalScore = maxScore then
  begin
    Writeln('All of adventuredom gives tribute');
    Writeln('to you, ADVENTURER GRAND MASTER!');
    Exit;
  end;
end;

procedure SaveGame;
var
  f: TextFile;
  i, j: Integer;
begin
  Assign(f, 'advent.sav');
  Rewrite(f);
  Writeln(f, currentRoom);
  Writeln(f, lightUnits);
  Writeln(f, darkFlag);
  Writeln(f, lightFlag);
  Writeln(f, playerScore);
  Writeln(f, ghostCount);
  Writeln(f, ghostActive);
  Writeln(f, ghostFlag);

  for i := 1 to MaxObjects do
    Writeln(f, objectLocation[i]);

  { Save the dynamic room-exit table (e.g. opened mansion door) }
  for i := 0 to MaxRooms do
    for j := 0 to 5 do
      Writeln(f, roomExit[i, j]);

  Close(f);
  Writeln('Game saved.');
end;

procedure LoadGame;
var
  f: TextFile;
  i, j, tempValue: Integer;
begin
  if not FileExists('advent.sav') then
  begin
    Writeln('No saved game found.');
    Exit;
  end;

  Assign(f, 'advent.sav');
  Reset(f);
  ReadLn(f, currentRoom);
  ReadLn(f, lightUnits);
  ReadLn(f, darkFlag);
  ReadLn(f, lightFlag);
  ReadLn(f, playerScore);
  ReadLn(f, ghostCount);
  ReadLn(f, ghostActive);
  ReadLn(f, ghostFlag);

  for i := 1 to MaxObjects do
  begin
    ReadLn(f, tempValue);
    objectLocation[i] := tempValue;
  end;

  { Restore the dynamic room-exit table }
  for i := 0 to MaxRooms do
    for j := 0 to 5 do
    begin
      ReadLn(f, tempValue);
      roomExit[i, j] := tempValue;
    end;

  Close(f);
  Writeln('Game loaded.');
end;

{ Forward declaration so ExecuteCommandActions can call LocateObjectByKeyword }
function LocateObjectByKeyword(const aKey: String): Integer; forward;

procedure ExecuteCommandActions(commandIdx: Integer);
var
  actionPos, actionType, actionVal1, actionVal2, tempObjectLoc: Integer;
begin
  actionPos := 17;
  while actionPos <= 34 do
  begin
    actionType := ExtractNumber(commandTable[commandIdx], actionPos, 2);
    actionVal1 := ExtractNumber(commandTable[commandIdx], actionPos + 2, 2);
    actionVal2 := ExtractNumber(commandTable[commandIdx], actionPos + 4, 2);

    case actionType of
      1:
        Writeln(messageTable[actionVal1], '.');

      2:
      begin
        tempObjectLoc := objectLocation[actionVal1];
        objectLocation[actionVal1] := objectLocation[actionVal2];
        objectLocation[actionVal2] := tempObjectLoc;
      end;

      3:
        objectLocation[actionVal1] := 0;

      4:
        objectLocation[actionVal1] := currentRoom;

      5:
      begin
        currentRoom := actionVal1;
        roomChanged := 1;
      end;

      6:
      begin
        deathHappened := 1;
        currentRoom := limboRoom;
        playerScore := playerScore - 5;
      end;

      7:
        TakeObject(LocateObjectByKeyword(nounPrefix));

      8:
      begin
        if nounPrefix <> 'TRE' then
        begin
          if word2 = '' then Writeln('be specific')
          else
            DropObject(LocateObjectByKeyword(nounPrefix));
        end
        else
          DropTreasure;
      end;

      9:
        objectLocation[actionVal1] := actionVal2;

      10:
        ShowInventory;

      77:
        deathHappened := 1;

      18:
        AttackGhost;

      11:
        roomChanged := 1;

      12:
        CalculateScore;

      13:
      begin
        quitFlag := 1;
        CalculateScore;
      end;

      14:
      begin
        if objectLocation[actionVal1] = -1 then Writeln(messageTable[actionVal1])
        else Writeln('I have nothing to read');
      end;

      15:
      begin
        if objectLocation[actionVal1] = -1 then Writeln('thanks I was hungery')
        else Writeln('I have nothing to eat');
      end;

      16:
        SaveGame;
    end;

    actionPos := actionPos + 6;
  end;
end;

procedure FindCommand;
var
  commandIndex, conditionPos, condType, condValue, startIdx, endIdx: Integer;
  conditionOk: Boolean;
  found: Boolean;
{Search command table for a record matching verbIndex/nounIndex and satisfying
all preconditions (object carried, player in room, etc.).}
begin
  matchFound := 0;
  matchedCommand := 0;
  found := False;

  if verbIndex > 17 then
  begin
    startIdx := 54;
    endIdx := MaxCommands;
  end
  else
  begin
    startIdx := 1;
    endIdx := 53;
  end;

  commandIndex := startIdx;
  while (commandIndex <= endIdx) and not found do
  begin
    if ExtractNumber(commandTable[commandIndex], 1, 2) <> verbIndex then
    begin
      Inc(commandIndex);
      Continue;
    end;

    if ExtractNumber(commandTable[commandIndex], 3, 2) <> 0 then
      if ExtractNumber(commandTable[commandIndex], 3, 2) <> nounIndex then
      begin
        Inc(commandIndex);
        Continue;
      end;

    matchFound := 1;
    conditionOk := True;
    conditionPos := 5;
    while conditionPos <= 16 do
    begin
      condType := ExtractNumber(commandTable[commandIndex], conditionPos, 2);
      condValue := ExtractNumber(commandTable[commandIndex], conditionPos + 2, 2);

      case condType of
        1:
          if objectLocation[condValue] <> -1 then conditionOk := False;
        2:
          if currentRoom <> condValue then conditionOk := False;
        3:
          if objectLocation[condValue] <> 0 then conditionOk := False;
        5:
          if objectLocation[condValue] <> currentRoom then conditionOk := False;
      end;

      conditionPos := conditionPos + 4;
    end;

    if conditionOk then
    begin
      matchedCommand := commandIndex;
      found := True;
    end
    else
      Inc(commandIndex);
  end;

  if not found then
  begin
    if matchFound = 1 then
      Writeln('I CAN''T DO THAT NOW.')
    else
      Writeln('I DON''T UNDERSTAND?');
    Exit;
  end;

  ExecuteCommandActions(matchedCommand);

  if deathHappened = 1 then
  begin
    Writeln;
    Exit;
  end;

  if roomChanged = 1 then
  begin
    Exit;
  end;
end;

function LocateObjectByKeyword(const aKey: String): Integer;
{Find object number by its 3-letter keyword, case-insensitive.}
var
  i: Integer;
begin
  for i := 1 to MaxObjects do
    if UpperCase(objectKeyword[i]) = UpperCase(aKey) then
    begin
      LocateObjectByKeyword := i;
      Exit;
    end;

  LocateObjectByKeyword := 0;
end;

procedure ProcessInput;
var
  synonymLoop, verbLoop, nounLoop: Integer;
{Parse the two-word input, resolve synonyms, and dispatch to movement or command table.}
begin
  if word1 = 'GO' then
  begin
    word1 := word2;
    word2 := '';
  end;

  if word1 = 'SAY' then
  begin
    word1 := word2;
    word2 := '';
  end;

  verbPrefix := Copy(word1, 1, 3);
  nounPrefix := Copy(word2, 1, 3);
  verbIndex := 0;
  nounIndex := 0;

  if (verbPrefix = 'FEE') and (nounPrefix = 'OYS') then nounPrefix := 'DOO';

  for synonymLoop := 1 to synonymCount do
    if verbPrefix = UpperCase(synonymShort[synonymLoop]) then verbPrefix := UpperCase(synonymLong[synonymLoop]);

  if (nounPrefix = 'HOU') or (nounPrefix = 'TRA') then nounPrefix := 'DOO';

  for verbLoop := 1 to MaxVerbs do
    if verbPrefix = UpperCase(verbTable[verbLoop]) then
    begin
      verbIndex := verbLoop;
      Break;
    end;

  if word2 <> '' then
  begin
    for nounLoop := 1 to MaxNouns do
      if nounPrefix = UpperCase(nounTable[nounLoop]) then
      begin
        nounIndex := nounLoop;
        Break;
      end;
  end;

  if verbIndex = 0 then
  begin
    Writeln('YOU USE WORD(S) I DON''T KNOW');
    Exit;
  end;

  if verbIndex < 7 then
  begin
    AttemptMove(verbIndex - 1);
    Exit;
  end;

  if verbIndex = 7 then
  begin
    TakeObject(LocateObjectByKeyword(nounPrefix));
    Exit;
  end;

  FindCommand;
end;

procedure ShowRoomDescription;
var
  printHeader, itemsFound, exitIndex, itemIndex, lineIndex: Integer;
{Print room name, visible items, and obvious exits.  Handle darkness.}
begin
  darkFlag := 0;

  if (currentRoom > deathRoom) and (objectLocation[lightObject] <> -1) and (objectLocation[lightObject] <> currentRoom) then darkFlag := 1;

  if (currentRoom = limboRoom) or (currentRoom = deathRoom) then darkFlag := 0;

  if darkFlag = 0 then
  begin
    if Copy(roomName[currentRoom], 1, 1) = '*' then
    begin
      roomName[currentRoom] := Copy(roomName[currentRoom], 2, Length(roomName[currentRoom]) - 1);
      Writeln(roomName[currentRoom], '.');
    end
    else
      Writeln('You''re in ', roomName[currentRoom], '.');

    if currentRoom = deathRoom then
    begin
      Writeln;
      playerScore := playerScore - 12;
      quitFlag := 1;
      Exit;
    end;

    printHeader := 1;
    itemsFound := 0;
    Writeln;

    for itemIndex := 1 to MaxObjects do
    begin
      if (objectLocation[itemIndex] = currentRoom) and (printHeader = 1) then
      begin
        Writeln('VISIBLE ITEMS HERE:');
        printHeader := 0;
        itemsFound := 1;
      end;

      if objectLocation[itemIndex] <> currentRoom then Continue;

      Writeln(objectName[itemIndex], '.  ');
    end;

    if itemsFound <> 0 then Writeln;

    printHeader := 1;
    Writeln;

    for exitIndex := 0 to 5 do
    begin
      if (roomExit[currentRoom, exitIndex] <> 0) and (printHeader = 1) then
      begin
        Writeln('OBVIOUS EXITS:');
        printHeader := 0;
      end;

      if roomExit[currentRoom, exitIndex] <> 0 then Write(verbTable[exitIndex + 1], ' ');
    end;

    Writeln;

    // Horizontal underscore line matching console width
    for lineIndex := 1 to ConsoleWidth do
      Write('_');

    Writeln;
    Writeln;
  end
  else
  begin
    Writeln('I CAN''T SEE IN THE DARK!');
    Writeln;
  end;
end;

procedure GameTurn;
var
  userInput: String;
  spacePos: Integer;
{One turn: decrement light, random events, read input, parse, execute.}
begin
  if objectLocation[lightObject] = -1 then lightUnits := lightUnits - 1;

  Inc(turnCount);

  CheckLight;
  ProcessRandomEvents;
  DescribeRoomEvents;

  if gameKilled = 1 then
  begin
    gameKilled := 0;
    playerScore := playerScore - 5;
    Exit;
  end;

  Writeln;
  Write('WHAT NEXT?  >');
  ReadLn(userInput);

  rawInput := userInput;

  if rawInput = '' then Exit;

  Writeln;

  word1 := '';
  word2 := '';

  spacePos := Pos(' ', rawInput);

  if spacePos > 0 then
  begin
    word1 := Copy(rawInput, 1, spacePos - 1);
    word2 := Copy(rawInput, spacePos + 1, Length(rawInput) - spacePos);
  end
  else
    word1 := rawInput;

  word1 := UpperCase(word1);
  word2 := UpperCase(word2);

  ProcessInput;
end;

{------------------------------------------------------------------------------
  INTRO / TITLE / SETUP
------------------------------------------------------------------------------}

procedure ShowInstructions;
begin
  Writeln;
  Writeln('This is adventure!!!');
  Writeln('I will be your eyes and hands as you');
  Writeln('search for lost treasure.');
  Writeln;

  Writeln('The object is to recover ', treasureCount, ' treasures');
  Writeln('and return them to the proper place.');
  Writeln('Treasures have a ''*'' in their name');
  Writeln;

  Writeln('Use two word commands consisting of');
  Writeln('a verb and a noun, example:');
  Writeln;

  Writeln('go west, take gold, enter hole, shoot');
  Writeln;

  Writeln('inventory, save game, drop treasure');
  Writeln;
  Writeln('Hit any key to continue ...');

  ReadKey;
  ClrScr;

  Writeln('       Words to Know                 ');
  Writeln('READ      - if you have something that can be read, you will read it.');
  Writeln('ENTER     - will take you into a hole, passage, building, etc..');
  Writeln('INVENTORY - gives you list of what you are carrying.');
  Writeln('LOOK      - describes the room you are in.');
  Writeln;

  Writeln('Use TAKE and DROP in most cases to manipulate objects.');
  Writeln;

  Writeln('There are many more words that will be discovered as you explore some may');
  Writeln('even be magic, usually when you tell me things you should use two words.');
  Writeln;

  Writeln('If you find one word doesn''t work just try another.');
  Writeln;

  Writeln('Please wait while I load my data...');
end;

procedure ShowTitleScreen;
begin
  ClrScr;

  //Writeln('                adventure  ');
  //Writeln('      N  N        M        -by-     ');
  //Writeln('     N  N      M     john o''hare ');
  //Writeln('    N  N        M');
  //Writeln('   N  N              M      VVVVVVV');
  //Writeln('  N  N              M    VVMVVVNVV');
  //Writeln('  P          VVVVVVVVV');
  //Writeln('            VVVMNMNMVV');
  //Writeln(' PP L     VVVVVVVVV');
  //Writeln(' P  M               M    V  M N V');
  //Writeln('     M               M  N   ');
  //Writeln('M   OOPP      ');
  //Writeln('PPPP   O        ');
  //Writeln('   .       ');
  //Writeln('L L     ');
  //Writeln(' MM           M      ');
  //Writeln('  PMOPOP     NVM');
  //Writeln('      PPPPPPPPPPPOOOOO   ');
  //Writeln('                  MM');
  //Writeln('                    ');
  //Writeln('                   M M');
  //Writeln('  ');
  //Writeln;
  //
  //Writeln('    hit any key to begin adventure');

  Writeln(' ADVENTURE 3:  The Haunted Mansion');
  Writeln('             -BY-');
  Writeln('          JOHN O''HARE');
  Writeln;
  Writeln('       Pascal conversion');
  Writeln('              by');
  Writeln('          SWG-Perkins');
  Writeln;
  Writeln;
  Writeln('Hit any key to begin adventure');
  ReadKey;
end;

procedure SetupGame;
{Initialize all game variables to starting values.}
begin
  Randomize;

  lightObject := 15;
  treasureValue := 15;
  treasureCount := 20;
  maxScore := treasureValue * treasureCount + 50;

  objectLimit := 10;

  treasureRoom := 7;
  limboRoom := 57;
  deathRoom := 58;

  adventureNumber := 3;

  lightUnits := 150;
  lightFlag := 2;

  ghostCount := 4;

  playerScore := 50;

  turnCount := 0;

  hubieActive := 0;

  ghostFlag := 0;
  ghostActive := 0;

  currentRoom := 1;
  darkFlag := 0;

  quitFlag := 0;
  gameKilled := 0;
end;

procedure PromptLoadGame;
var
  answer: String;
begin
  Writeln;

  Write('Use saved game (y/n)? ');
  ReadLn(answer);

  if LowerCase(answer) = 'y' then
  begin
    LoadGame;
  end;
end;

{------------------------------------------------------------------------------
  MAIN
------------------------------------------------------------------------------}
begin
  InitNouns;
  InitVerbs;
  InitRooms;
  InitObjects;
  InitMessages;
  InitCommands;
  InitSynonyms;
  InitEvents;

  ShowTitleScreen;

  ClrScr;                       // clear after title screen

  ShowInstructions;

  WaitForKey;

  ClrScr;                       // clear after instructions

  SetupGame;

  PromptLoadGame;

  timeString := FormatDateTime('hh:nn am/pm', Now);

  ClrScr;                       // clear after entering time

  displayRoom := True;

  while True do
  begin
    if currentRoom = deathRoom then
    begin
      CalculateScore;
      Break;
    end;

    if currentRoom = limboRoom then
    begin
      currentRoom := 1;
      playerScore := playerScore - 5;
      displayRoom := True;      // arriving in limbo sends you to room 1; show it
    end;

    if displayRoom then
    begin
      ClrScr;                   // clear only when entering a (new) room
      ShowRoomDescription;
      displayRoom := False;
    end;

    if quitFlag = 1 then Break;

    GameTurn;

    if deathHappened = 1 then
    begin
      deathHappened := 0;
      currentRoom := limboRoom;
      playerScore := playerScore - 5;
      gameKilled := 1;
      Continue;
    end;

    if roomChanged = 1 then
    begin
      roomChanged := 0;
      displayRoom := True;      // schedule clear + room description for new room
      Continue;
    end;
  end;

  Writeln;
  Writeln('Thanks for playing Adventure 1.5!');
  Writeln;
  WaitForKey;
end.

