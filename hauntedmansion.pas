program HauntedMansion;

{$mode objfpc}{$H+}

uses
  SysUtils, StrUtils, Crt;

const
  MaxN = 36;
  MaxV = 32;
  MaxR = 58;
  MaxO = 78;
  MaxM = 59;
  MaxC = 91;

var
  lu, lf, lt, tv, t7, mxv, ol, tr, lb, dt, ad, r, df, so, gn, ga, gf, ht, ha: Integer;
  obLoc : array[0..MaxO] of Integer;
  obSize: array[0..MaxO] of Integer;
  obName: array[0..MaxO] of String;
  obKey : array[0..MaxO] of String;
  rmName: array[0..MaxR] of String;
  rmExit: array[0..MaxR, 0..5] of Integer;
  noun  : array[0..MaxN] of String;
  verb  : array[0..MaxV] of String;
  msg   : array[0..MaxM] of String;
  cmd   : array[1..MaxC] of String;
  w1    : array[1..20] of String;
  w2    : array[1..20] of String;
  w0    : Integer;
  e4    : String;
  eMsg  : array[1..7] of String;
  hsMsg : array[1..3] of String;
  e5    : String;

  jp, c7, i1, i2, mf, k, an, x, uf, oe, af, dh, rf, rc, h, e, qf, sc, sb, gk: Integer;
  ip, i1s, i2s, v1s, n1s, tm: String;
  vi, pq, os, td, w3, vl, nl, y, z, g, ob: Integer;
  c1, c2, a1, a2, a3: Integer;

function GetNum(const s: String; start, len: Integer): Integer;
var
  code, v: Integer;
  st: String;
begin
  st := Copy(s, start, len);
  Val(st, v, code);
  if code <> 0 then v := 0;
  GetNum := v;
end;

function RndRange(x: Integer): Integer;
begin
  if x <= 0 then Exit(0);
  Result := Random(x) + 1;
end;

procedure PauseAnyKey;
var
  ch: Char;
begin
  Write('Hit any key to continue ... ');
  ch := ReadKey;
  Writeln;
end;

procedure InitNouns;
begin
  noun[0] := 'nnn'; noun[1] := 'mai'; noun[2] := 'big'; noun[3] := 'spi'; noun[4] := 'let';
  noun[5] := 'doo'; noun[6] := 'mat'; noun[7] := 'but'; noun[8] := 'kni'; noun[9] := 'bot';
  noun[10] := 'liq'; noun[11] := 'des'; noun[12] := 'oys'; noun[13] := 'pap'; noun[14] := 'red';
  noun[15] := 'blu'; noun[16] := 'gre'; noun[17] := 'boo'; noun[18] := 'gol'; noun[19] := 'clo';
  noun[20] := 'cof'; noun[21] := 'pot'; noun[22] := 'sta'; noun[23] := 'lad'; noun[24] := 'gun';
  noun[25] := 'cro'; noun[26] := 'tru'; noun[27] := 'rug'; noun[28] := 'gob'; noun[29] := 'gho';
  noun[30] := 'tro'; noun[31] := 'sig'; noun[32] := 'fla'; noun[33] := 'win'; noun[34] := 'gam';
  noun[35] := 'pas';
end;

procedure InitVerbs;
begin
  verb[0] := 'vvv'; verb[1] := 'nor'; verb[2] := 'sou'; verb[3] := 'eas'; verb[4] := 'wes';
  verb[5] := 'up'; verb[6] := 'dow'; verb[7] := 'tak'; verb[8] := 'dro'; verb[9] := 'ent';
  verb[10] := 'inv'; verb[11] := 'loo'; verb[12] := 'sco'; verb[13] := 'qui'; verb[14] := 'hel';
  verb[15] := 'pus'; verb[16] := 'rea'; verb[17] := 'ope'; verb[18] := 'mov'; verb[19] := 'sho';
  verb[20] := 'run'; verb[21] := 'kil'; verb[22] := 'eat'; verb[23] := 'cli'; verb[24] := 'tur';
  verb[25] := 'on'; verb[26] := 'off'; verb[27] := 'dri'; verb[28] := 'cbm'; verb[29] := 'sav';
  verb[30] := 'thr'; verb[31] := 'sta';
end;

procedure InitRooms;
begin
  rmName[0] := '';
  rmExit[0,0] := 0; rmExit[0,1] := 0; rmExit[0,2] := 0; rmExit[0,3] := 0; rmExit[0,4] := 0; rmExit[0,5] := 0;

  rmName[1] := '*You''re on an old worn path';
  rmExit[1,0] := 6; rmExit[1,1] := 0; rmExit[1,2] := 1; rmExit[1,3] := 2; rmExit[1,4] := 0; rmExit[1,5] := 0;

  rmName[2] := '*You''re walking along an old path';
  rmExit[2,0] := 5; rmExit[2,1] := 0; rmExit[2,2] := 1; rmExit[2,3] := 3; rmExit[2,4] := 0; rmExit[2,5] := 0;

  rmName[3] := 'front of a big spooky house';
  rmExit[3,0] := 0; rmExit[3,1] := 7; rmExit[3,2] := 2; rmExit[3,3] := 4; rmExit[3,4] := 0; rmExit[3,5] := 0;

  rmName[4] := 'the haunted forest';
  rmExit[4,0] := 5; rmExit[4,1] := 4; rmExit[4,2] := 4; rmExit[4,3] := 5; rmExit[4,4] := 0; rmExit[4,5] := 0;

  rmName[5] := 'the haunted forest';
  rmExit[5,0] := 4; rmExit[5,1] := 4; rmExit[5,2] := 6; rmExit[5,3] := 4; rmExit[5,4] := 0; rmExit[5,5] := 0;

  rmName[6] := 'the haunted forest';
  rmExit[6,0] := 5; rmExit[6,1] := 4; rmExit[6,2] := 1; rmExit[6,3] := 5; rmExit[6,4] := 0; rmExit[6,5] := 0;

  rmName[7] := '*You''re on the porch of the old house';
  rmExit[7,0] := 3; rmExit[7,1] := 0; rmExit[7,2] := 0; rmExit[7,3] := 0; rmExit[7,4] := 0; rmExit[7,5] := 0;

  rmName[8] := 'an old dusty living room';
  rmExit[8,0] := 7; rmExit[8,1] := 12; rmExit[8,2] := 9; rmExit[8,3] := 0; rmExit[8,4] := 0; rmExit[8,5] := 0;

  rmName[9] := 'the dining room';
  rmExit[9,0] := 0; rmExit[9,1] := 13; rmExit[9,2] := 10; rmExit[9,3] := 8; rmExit[9,4] := 0; rmExit[9,5] := 0;

  rmName[10] := 'the kitchen';
  rmExit[10,0] := 0; rmExit[10,1] := 0; rmExit[10,2] := 11; rmExit[10,3] := 9; rmExit[10,4] := 0; rmExit[10,5] := 0;

  rmName[11] := 'a musty old pantry';
  rmExit[11,0] := 0; rmExit[11,1] := 0; rmExit[11,2] := 0; rmExit[11,3] := 10; rmExit[11,4] := 0; rmExit[11,5] := 0;

  rmName[12] := 'the family room';
  rmExit[12,0] := 8; rmExit[12,1] := 0; rmExit[12,2] := 13; rmExit[12,3] := 0; rmExit[12,4] := 0; rmExit[12,5] := 0;

  rmName[13] := 'a small alcove';
  rmExit[13,0] := 9; rmExit[13,1] := 16; rmExit[13,2] := 0; rmExit[13,3] := 12; rmExit[13,4] := 26; rmExit[13,5] := 0;

  rmName[14] := 'the study';
  rmExit[14,0] := 0; rmExit[14,1] := 17; rmExit[14,2] := 0; rmExit[14,3] := 0; rmExit[14,4] := 0; rmExit[14,5] := 0;

  rmName[15] := '*You''re at the west end of a corridor';
  rmExit[15,0] := 0; rmExit[15,1] := 18; rmExit[15,2] := 16; rmExit[15,3] := 0; rmExit[15,4] := 0; rmExit[15,5] := 0;

  rmName[16] := 'the middle of a corridor';
  rmExit[16,0] := 13; rmExit[16,1] := 19; rmExit[16,2] := 17; rmExit[16,3] := 15; rmExit[16,4] := 0; rmExit[16,5] := 0;

  rmName[17] := '*You''re at the east end of a corridor';
  rmExit[17,0] := 14; rmExit[17,1] := 20; rmExit[17,2] := 0; rmExit[17,3] := 16; rmExit[17,4] := 0; rmExit[17,5] := 0;

  rmName[18] := 'the Den';
  rmExit[18,0] := 15; rmExit[18,1] := 0; rmExit[18,2] := 0; rmExit[18,3] := 0; rmExit[18,4] := 0; rmExit[18,5] := 0;

  rmName[19] := 'the Library';
  rmExit[19,0] := 16; rmExit[19,1] := 0; rmExit[19,2] := 0; rmExit[19,3] := 0; rmExit[19,4] := 0; rmExit[19,5] := 0;

  rmName[20] := 'a Guest Room';
  rmExit[20,0] := 17; rmExit[20,1] := 0; rmExit[20,2] := 0; rmExit[20,3] := 21; rmExit[20,4] := 0; rmExit[20,5] := 0;

  rmName[21] := 'a dusty closet';
  rmExit[21,0] := 0; rmExit[21,1] := 0; rmExit[21,2] := 20; rmExit[21,3] := 0; rmExit[21,4] := 0; rmExit[21,5] := 0;

  rmName[22] := 'the trophy room';
  rmExit[22,0] := 0; rmExit[22,1] := 25; rmExit[22,2] := 0; rmExit[22,3] := 0; rmExit[22,4] := 0; rmExit[22,5] := 0;

  rmName[23] := 'an old dusty nursery';
  rmExit[23,0] := 0; rmExit[23,1] := 26; rmExit[23,2] := 0; rmExit[23,3] := 0; rmExit[23,4] := 0; rmExit[23,5] := 0;

  rmName[24] := 'a large bathroom';
  rmExit[24,0] := 0; rmExit[24,1] := 27; rmExit[24,2] := 0; rmExit[24,3] := 0; rmExit[24,4] := 0; rmExit[24,5] := 0;

  rmName[25] := '*You''re at the west end of a hallway';
  rmExit[25,0] := 22; rmExit[25,1] := 28; rmExit[25,2] := 26; rmExit[25,3] := 0; rmExit[25,4] := 0; rmExit[25,5] := 0;

  rmName[26] := 'a stairwell';
  rmExit[26,0] := 23; rmExit[26,1] := 31; rmExit[26,2] := 27; rmExit[26,3] := 25; rmExit[26,4] := 0; rmExit[26,5] := 13;

  rmName[27] := '*You''re at the east end of a hallway';
  rmExit[27,0] := 24; rmExit[27,1] := 32; rmExit[27,2] := 0; rmExit[27,3] := 26; rmExit[27,4] := 0; rmExit[27,5] := 0;

  rmName[28] := 'the master bedroom';
  rmExit[28,0] := 25; rmExit[28,1] := 0; rmExit[28,2] := 0; rmExit[28,3] := 29; rmExit[28,4] := 0; rmExit[28,5] := 0;

  rmName[29] := 'a dark, dusty closet. A ladder leads up here';
  rmExit[29,0] := 0; rmExit[29,1] := 0; rmExit[29,2] := 28; rmExit[29,3] := 0; rmExit[29,4] := 30; rmExit[29,5] := 0;

  rmName[30] := '*You''re on the ladder';
  rmExit[30,0] := 0; rmExit[30,1] := 0; rmExit[30,2] := 0; rmExit[30,3] := 0; rmExit[30,4] := 0; rmExit[30,5] := 29;

  rmName[31] := 'a yellow bedroom';
  rmExit[31,0] := 26; rmExit[31,1] := 0; rmExit[31,2] := 0; rmExit[31,3] := 0; rmExit[31,4] := 0; rmExit[31,5] := 0;

  rmName[32] := 'a white bedroom';
  rmExit[32,0] := 27; rmExit[32,1] := 0; rmExit[32,2] := 0; rmExit[32,3] := 0; rmExit[32,4] := 0; rmExit[32,5] := 0;

  rmName[33] := 'the west end of the attic';
  rmExit[33,0] := 0; rmExit[33,1] := 0; rmExit[33,2] := 34; rmExit[33,3] := 0; rmExit[33,4] := 0; rmExit[33,5] := 30;

  rmName[34] := 'the east end of the attic';
  rmExit[34,0] := 0; rmExit[34,1] := 35; rmExit[34,2] := 0; rmExit[34,3] := 33; rmExit[34,4] := 0; rmExit[34,5] := 0;

  rmName[35] := 'a dirty old storeroom';
  rmExit[35,0] := 34; rmExit[35,1] := 0; rmExit[35,2] := 0; rmExit[35,3] := 0; rmExit[35,4] := 0; rmExit[35,5] := 0;

  rmName[36] := 'the basement, there is a large open door to the south';
  rmExit[36,0] := 0; rmExit[36,1] := 40; rmExit[36,2] := 0; rmExit[36,3] := 37; rmExit[36,4] := 10; rmExit[36,5] := 0;

  rmName[37] := 'a laundry room';
  rmExit[37,0] := 0; rmExit[37,1] := 0; rmExit[37,2] := 36; rmExit[37,3] := 38; rmExit[37,4] := 0; rmExit[37,5] := 0;

  rmName[38] := 'a musty, old room in the      basement';
  rmExit[38,0] := 0; rmExit[38,1] := 39; rmExit[38,2] := 37; rmExit[38,3] := 0; rmExit[38,4] := 0; rmExit[38,5] := 0;

  rmName[39] := 'an old wine cellar';
  rmExit[39,0] := 38; rmExit[39,1] := 0; rmExit[39,2] := 0; rmExit[39,3] := 0; rmExit[39,4] := 0; rmExit[39,5] := 0;

  rmName[40] := 'a chilly, damp room';
  rmExit[40,0] := 36; rmExit[40,1] := 0; rmExit[40,2] := 0; rmExit[40,3] := 0; rmExit[40,4] := 0; rmExit[40,5] := 0;

  rmName[41] := 'a secret underground cavern';
  rmExit[41,0] := 0; rmExit[41,1] := 42; rmExit[41,2] := 0; rmExit[41,3] := 0; rmExit[41,4] := 40; rmExit[41,5] := 0;

  rmName[42] := 'a narrow passage';
  rmExit[42,0] := 41; rmExit[42,1] := 0; rmExit[42,2] := 43; rmExit[42,3] := 0; rmExit[42,4] := 0; rmExit[42,5] := 0;

  rmName[43] := 'a drafty chamber';
  rmExit[43,0] := 0; rmExit[43,1] := 0; rmExit[43,2] := 44; rmExit[43,3] := 42; rmExit[43,4] := 0; rmExit[43,5] := 0;

  rmName[44] := 'a large circular chamber';
  rmExit[44,0] := 45; rmExit[44,1] := 0; rmExit[44,2] := 46; rmExit[44,3] := 43; rmExit[44,4] := 0; rmExit[44,5] := 0;

  rmName[45] := 'a splendid chamber 30 feet    high';
  rmExit[45,0] := 47; rmExit[45,1] := 44; rmExit[45,2] := 0; rmExit[45,3] := 0; rmExit[45,4] := 0; rmExit[45,5] := 0;

  rmName[46] := 'a roughly carved room, a pit  leads down';
  rmExit[46,0] := 0; rmExit[46,1] := 52; rmExit[46,2] := 0; rmExit[46,3] := 44; rmExit[46,4] := 0; rmExit[46,5] := 53;

  rmName[47] := '*You''re at a junction of three passages';
  rmExit[47,0] := 0; rmExit[47,1] := 45; rmExit[47,2] := 48; rmExit[47,3] := 56; rmExit[47,4] := 0; rmExit[47,5] := 0;

  rmName[48] := 'a dusty passage';
  rmExit[48,0] := 0; rmExit[48,1] := 0; rmExit[48,2] := 49; rmExit[48,3] := 47; rmExit[48,4] := 0; rmExit[48,5] := 0;

  rmName[49] := 'an old broken passage';
  rmExit[49,0] := 0; rmExit[49,1] := 0; rmExit[49,2] := 50; rmExit[49,3] := 48; rmExit[49,4] := 0; rmExit[49,5] := 0;

  rmName[50] := '*You''re at a turn in the passage';
  rmExit[50,0] := 0; rmExit[50,1] := 51; rmExit[50,2] := 0; rmExit[50,3] := 49; rmExit[50,4] := 0; rmExit[50,5] := 0;

  rmName[51] := 'a TORTURE CHAMBER';
  rmExit[51,0] := 50; rmExit[51,1] := 0; rmExit[51,2] := 0; rmExit[51,3] := 0; rmExit[51,4] := 0; rmExit[51,5] := 0;

  rmName[52] := 'a cold damp room';
  rmExit[52,0] := 46; rmExit[52,1] := 0; rmExit[52,2] := 0; rmExit[52,3] := 0; rmExit[52,4] := 0; rmExit[52,5] := 0;

  rmName[53] := 'a pit';
  rmExit[53,0] := 0; rmExit[53,1] := 0; rmExit[53,2] := 0; rmExit[53,3] := 0; rmExit[53,4] := 0; rmExit[53,5] := 54;

  rmName[54] := 'a pit';
  rmExit[54,0] := 0; rmExit[54,1] := 0; rmExit[54,2] := 0; rmExit[54,3] := 0; rmExit[54,4] := 0; rmExit[54,5] := 55;

  rmName[55] := 'a pit.  There are no exits';
  rmExit[55,0] := 0; rmExit[55,1] := 0; rmExit[55,2] := 0; rmExit[55,3] := 0; rmExit[55,4] := 0; rmExit[55,5] := 0;

  rmName[56] := 'a dead end passage';
  rmExit[56,0] := 0; rmExit[56,1] := 0; rmExit[56,2] := 47; rmExit[56,3] := 0; rmExit[56,4] := 0; rmExit[56,5] := 0;

  rmName[57] := ' a misty room with strange    looking exits';
  rmExit[57,0] := 1; rmExit[57,1] := 58; rmExit[57,2] := 58; rmExit[57,3] := 58; rmExit[57,4] := 5; rmExit[57,5] := 58;

  rmName[58] := ' H E L L ';
  rmExit[58,0] := 0; rmExit[58,1] := 0; rmExit[58,2] := 0; rmExit[58,3] := 0; rmExit[58,4] := 0; rmExit[58,5] := 0;
end;

procedure InitObjects;
begin
  obName[0] := ''; obKey[0] := ''; obSize[0] := 0; obLoc[0] := 0;

  obName[1] := 'MAILBOX (name on it:  Hubie Marsten)'; obKey[1] := 'mai'; obSize[1] := 1; obLoc[1] := 3;
  obName[2] := 'ring of keys'; obKey[2] := 'key'; obSize[2] := 0; obLoc[2] := 0;
  obName[3] := 'old letter'; obKey[3] := 'let'; obSize[3] := 0; obLoc[3] := 0;
  obName[4] := 'LARGE PADLOCKED DOOR'; obKey[4] := 'doo'; obSize[4] := 1; obLoc[4] := 7;
  obName[5] := 'OPEN DOOR'; obKey[5] := 'doo'; obSize[5] := 1; obLoc[5] := 0;
  obName[6] := 'doormat'; obKey[6] := 'mat'; obSize[6] := 0; obLoc[6] := 7;
  obName[7] := 'BUTTON BY DOOR (doorbell?)'; obKey[7] := 'but'; obSize[7] := 1; obLoc[7] := 7;
  obName[8] := 'SIGN - LEAVE TREASURE HERE SAYS SCORE'; obKey[8] := 'sig'; obSize[8] := 1; obLoc[8] := 7;
  obName[9] := 'FURNITURE'; obKey[9] := 'fur'; obSize[9] := 1; obLoc[9] := 8;
  obName[10] := 'TABLE & CHAIRS'; obKey[10] := 'tab'; obSize[10] := 1; obLoc[10] := 9;
  obName[11] := '*silver candlesticks*'; obKey[11] := 'can'; obSize[11] := 0; obLoc[11] := 9;
  obName[12] := '*silver knife*'; obKey[12] := 'kni'; obSize[12] := 0; obLoc[12] := 10;
  obName[13] := 'pool of blood'; obKey[13] := 'blo'; obSize[13] := 1; obLoc[13] := 10;
  obName[14] := 'BIG MAC'; obKey[14] := 'big'; obSize[14] := 0; obLoc[14] := 10;
  obName[15] := 'vial of strange liquid'; obKey[15] := 'via'; obSize[15] := 0; obLoc[15] := 11;
  obName[16] := '*wallet full of $100s*'; obKey[16] := 'wal'; obSize[16] := 0; obLoc[16] := 12;
  obName[17] := 'DESK'; obKey[17] := 'des'; obSize[17] := 1; obLoc[17] := 14;
  obName[18] := 'slip of paper'; obKey[18] := 'pap'; obSize[18] := 0; obLoc[18] := 0;
  obName[19] := 'magic gun'; obKey[19] := 'gun'; obSize[19] := 0; obLoc[19] := 0;
  obName[20] := '*gold watch*'; obKey[20] := 'wat'; obSize[20] := 0; obLoc[20] := 18;
  obName[21] := '*rare painting*'; obKey[21] := 'pai'; obSize[21] := 0; obLoc[21] := 18;
  obName[22] := 'red book'; obKey[22] := 'red'; obSize[22] := 0; obLoc[22] := 19;
  obName[23] := 'blue book'; obKey[23] := 'blu'; obSize[23] := 0; obLoc[23] := 19;
  obName[24] := 'green book'; obKey[24] := 'gre'; obSize[24] := 0; obLoc[24] := 19;
  obName[25] := '*gold book*'; obKey[25] := 'gol'; obSize[25] := 0; obLoc[25] := 0;
  obName[26] := 'CLOSET'; obKey[26] := 'xxx'; obSize[26] := 1; obLoc[26] := 20;
  obName[27] := 'bed'; obKey[27] := 'bed'; obSize[27] := 1; obLoc[27] := 20;
  obName[28] := '*oriental rug*'; obKey[28] := 'rug'; obSize[28] := 0; obLoc[28] := 20;
  obName[29] := 'cloths'; obKey[29] := 'clo'; obSize[29] := 1; obLoc[29] := 21;
  obName[30] := '*mink*'; obKey[30] := 'min'; obSize[30] := 0; obLoc[30] := 21;
  obName[31] := '*gold medal*'; obKey[31] := 'med'; obSize[31] := 0; obLoc[31] := 22;
  obName[32] := 'crib'; obKey[32] := 'cri'; obSize[32] := 1; obLoc[32] := 23;
  obName[33] := '* $1000 savings bond *'; obKey[33] := 'bon'; obSize[33] := 0; obLoc[33] := 23;
  obName[34] := 'toilet'; obKey[34] := 'toi'; obSize[34] := 1; obLoc[34] := 24;
  obName[35] := 'sink'; obKey[35] := 'sin'; obSize[35] := 1; obLoc[35] := 24;
  obName[36] := 'a bubbling potion'; obKey[36] := 'pot'; obSize[36] := 0; obLoc[36] := 24;
  obName[37] := 'stairs going down'; obKey[37] := 'sta'; obSize[37] := 1; obLoc[37] := 26;
  obName[38] := 'wooden cross'; obKey[38] := 'cro'; obSize[38] := 0; obLoc[38] := 26;
  obName[39] := 'CLOSET'; obKey[39] := 'xxx'; obSize[39] := 1; obLoc[39] := 28;
  obName[40] := '*pearl necklace*'; obKey[40] := 'nec'; obSize[40] := 0; obLoc[40] := 28;
  obName[41] := 'bed'; obKey[41] := 'bed'; obSize[41] := 1; obLoc[41] := 28;
  obName[42] := '*velvet pillow*'; obKey[42] := 'pil'; obSize[42] := 0; obLoc[42] := 28;
  obName[43] := 'ladder'; obKey[43] := 'lad'; obSize[43] := 1; obLoc[43] := 29;
  obName[44] := 'furniture'; obKey[44] := 'fur'; obSize[44] := 1; obLoc[44] := 31;
  obName[45] := '*Commodore PET*'; obKey[45] := 'pet'; obSize[45] := 0; obLoc[45] := 31;
  obName[46] := 'furniture'; obKey[46] := 'fur'; obSize[46] := 1; obLoc[46] := 32;
  obName[47] := 'cobwebs'; obKey[47] := 'cob'; obSize[47] := 1; obLoc[47] := 33;
  obName[48] := '*rare family jewels*'; obKey[48] := 'jew'; obSize[48] := 0; obLoc[48] := 34;
  obName[49] := 'A body hanging from a noose (Hubie?)'; obKey[49] := 'bod'; obSize[49] := 1; obLoc[49] := 35;
  obName[50] := 'old trunk'; obKey[50] := 'tru'; obSize[50] := 1; obLoc[50] := 35;
  obName[51] := '*rare coins*'; obKey[51] := 'coi'; obSize[51] := 0; obLoc[51] := 0;
  obName[52] := '*bottle of rare imported wine*'; obKey[52] := 'win'; obSize[52] := 0; obLoc[52] := 39;
  obName[53] := 'An old wooden Coffin'; obKey[53] := 'cof'; obSize[53] := 1; obLoc[53] := 40;
  obName[54] := 'A dangerous GOBLIN'; obKey[54] := 'gob'; obSize[54] := 2; obLoc[54] := 45;
  obName[55] := 'A mean TROLL'; obKey[55] := 'tro'; obSize[55] := 2; obLoc[55] := 43;
  obName[56] := 'a torture rack'; obKey[56] := 'rac'; obSize[56] := 1; obLoc[56] := 51;
  obName[57] := '*gold death mask*'; obKey[57] := 'mas'; obSize[57] := 0; obLoc[57] := 51;
  obName[58] := 'GIANT OYSTER'; obKey[58] := 'oys'; obSize[58] := 1; obLoc[58] := 52;
  obName[59] := '*sack of diamonds*'; obKey[59] := 'dia'; obSize[59] := 0; obLoc[59] := 55;
  obName[60] := '*large ruby*'; obKey[60] := 'rub'; obSize[60] := 0; obLoc[60] := 56;
  obName[61] := 'A GHOST'; obKey[61] := 'gho'; obSize[61] := 2; obLoc[61] := 0;
  obName[62] := 'flashlight(on)'; obKey[62] := 'fla'; obSize[62] := 0; obLoc[62] := 0;
  obName[63] := 'flashlight(off)'; obKey[63] := 'fla'; obSize[63] := 0; obLoc[63] := 11;
  obName[64] := 'large rug'; obKey[64] := 'xxx'; obSize[64] := 1; obLoc[64] := 10;
  obName[65] := 'locked trapdoor'; obKey[65] := 'tra'; obSize[65] := 1; obLoc[65] := 0;
  obName[66] := 'open trapdoor'; obKey[66] := 'tra'; obSize[66] := 1; obLoc[66] := 0;
  obName[67] := 'locked trapdoor'; obKey[67] := 'tra'; obSize[67] := 1; obLoc[67] := 30;
  obName[68] := 'open trapdoor'; obKey[68] := 'tra'; obSize[68] := 1; obLoc[68] := 0;
  obName[69] := '*giant pearl*'; obKey[69] := 'pea'; obSize[69] := 0; obLoc[69] := 0;
  obName[70] := 'stairs going up'; obKey[70] := 'sta'; obSize[70] := 1; obLoc[70] := 13;
  obName[71] := 'cobwebs'; obKey[71] := 'cob'; obSize[71] := 1; obLoc[71] := 8;
  obName[72] := 'SIGN SAYS - YOU SHALL DIE....'; obKey[72] := 'sig'; obSize[72] := 1; obLoc[72] := 5;
  obName[73] := '-Barlow the Vampire-'; obKey[73] := 'vam'; obSize[73] := 2; obLoc[73] := 0;
  obName[74] := 'The spirit of Hubie Marston'; obKey[74] := 'spi'; obSize[74] := 1; obLoc[74] := 0;
  obName[75] := 'empty vial'; obKey[75] := 'via'; obSize[75] := 0; obLoc[75] := 0;
  obName[76] := 'sweet smelling broken glass'; obKey[76] := 'gla'; obSize[76] := 0; obLoc[76] := 0;
  obName[77] := 'PASSAGE'; obKey[77] := 'pas'; obSize[77] := 1; obLoc[77] := 0;
  obName[78] := 'empty bottle'; obKey[78] := 'bot'; obSize[78] := 0; obLoc[78] := 0;
end;

procedure InitMessages;
begin
  msg[1] := 'nothing happens';
  msg[2] := 'how should I know what to do';
  msg[3] := 'I''M DEAD';
  msg[4] := 'a couple things fell out';
  msg[5] := 'something fell out';
  msg[6] := 'the trapdoor creaks open';
  msg[7] := 'the door creaks open';
  msg[8] := 'It says: those who enter may not leave  here''s a hint they may need';
  msg[9] := 'If something is too heavy to take, try   to move it';
  msg[10] := 'OK, I moved it';
  msg[11] := 'OK, weird laughing comes from the house';
  msg[12] := 'the troll drinks the potion and turns   into a frog, the frog hops away';
  msg[13] := 'you got him.  The goblin and disappears in a cloud of black smoke';
  msg[14] := 'Barlow turns to dust                    and blows away';
  msg[15] := 'The ghost vaporizes';
  msg[16] := 'It''s poison  I''m dead!';
  msg[17] := 'Everything changes and....';
  msg[18] := 'BANG BANG BANG';
  msg[19] := 'you got him';
  msg[20] := 'you missed';
  msg[21] := 'it says - Hubie is harmless';
  msg[22] := 'It says:';
  msg[23] := 'This book is a treasure';
  msg[24] := 'The bottle of wine drops with a CRASH!';
  msg[25] := 'It''s empty';
  msg[26] := 'some treasures may be weapons           shoot goblin-troll potion!';
  msg[27] := 'say CBM';
  msg[28] := 'Kill a Vampire with *silver*            when trapped, take a drink';
  msg[29] := 'indentify book by color';
  msg[30] := 'I don''t have it';
  msg[31] := 'Where?!?';
  msg[32] := 'The BLUE book turns into a *gold* book';
  msg[33] := 'thanks I was hungery';
  msg[34] := 'the flashlight is on';
  msg[35] := 'the flashlight is off';
  msg[36] := 'I can''t move that!';
  msg[37] := 'there was something under it';
  msg[38] := 'OK,';
  msg[39] := 'It''s locked';
  msg[40] := 'It''s to heavy';
  msg[41] := 'I need a key';
  msg[42] := 'The oyster opens up to eat the BIG MAC  and a pearl rolls out!';
  msg[43] := 'The bottle lands softly on the pillow';
  msg[44] := 'A voice booms out.....PLEASE LEAVE IT ALONE!';
  msg[45] := 'The lid of the Coffin rises and Barlow  the vampire jumps out!!!';
  msg[46] := 'I don''t see it here';
  msg[47] := 'HOW?!?';
  msg[48] := 'I have nothing to read';
  msg[49] := 'NOTWELCOME';
  msg[50] := 'closets aren''t closed';
  msg[51] := 'I have nothing to eat';
  msg[52] := 'I have nothing to drink';
  msg[53] := 'I don''t have a gun';
  msg[54] := 'I don''t have a knife';
  msg[55] := 'Barlow stops me!';
  msg[56] := 'There is nothing to attack here';
  msg[57] := 'The bullets bounce off the shell!';
  msg[58] := 'He only eats big macs and I don''t       have one';
  msg[59] := 'hic hic, burp.  Boy was that good!';
end;

procedure InitCommands;
var
  i: Integer;
begin
  for i := 1 to MaxC do cmd[i] := '';
  cmd[1]  := '1000000000000000100000000000000000';
  cmd[2]  := '1100000000000000110000000000000000';
  cmd[3]  := '1200000000000000120000000000000000';
  cmd[4]  := '1300000000000000130000000000000000';
  cmd[5]  := '0712055800000000014000000000000000';
  cmd[6]  := '0720055300000000014000000000000000';
  cmd[7]  := '0726055000000000014000000000000000';
  cmd[8]  := '0717000000000000012900000000000000';
  cmd[9]  := '0731000000000000014400000000000000';
  cmd[10] := '0727056400000000014000000000000000';
  cmd[11] := '0732056300000000146300000000000000';
  cmd[12] := '0802055803690114014200046900031400';
  cmd[13] := '0802055800000000015800000000000000';
  cmd[14] := '0821055501360000011200035500033600';
  cmd[15] := '0832016300000000156300000000000000';
  cmd[16] := '0817000000000000012900000000000000';
  cmd[17] := '0905050400000000013900000000000000';
  cmd[18] := '0833015205420000014300155200000000';
  cmd[19] := '0833015200000000012400155200025276';
  cmd[20] := '0700000000000000070000000000000000';
  cmd[21] := '0800000000000000080000000000000000';
  cmd[22] := '0905050500000000050800000000000000';
  cmd[23] := '0905056600000000053600000000000000';
  cmd[24] := '0905056800000000053300000000000000';
  cmd[25] := '0919052600000000052100000000000000';
  cmd[26] := '0919053900000000052900000000000000';
  cmd[27] := '0935057700000000054100000000000000';
  cmd[28] := '1400000000000000010200000000000000';
  cmd[29] := '1507050700000000011100000000000000';
  cmd[30] := '1604010300000000010800010900000000';
  cmd[31] := '1606050600000000012200014900000000';
  cmd[32] := '1613011800000000012100000000000000';
  cmd[33] := '1617000000000000012900000000000000';
  cmd[34] := '1614012200000000012200012600000000';
  cmd[35] := '1615012300000000012200012700000000';
  cmd[36] := '1616012400000000012200012800000000';
  cmd[37] := '1618012500000000012200012300000000';
  cmd[38] := '1600000000000000014800000000000000';
  cmd[39] := '1720037305530000012500014500047300';
  cmd[40] := '1720055300000000012500000000000000';
  cmd[41] := '1705050401020000010700020405170108';
  cmd[42] := '1701050103020303010400040300040200';
  cmd[43] := '1701050100000000012500000000000000';
  cmd[44] := '1705056501020000010600026566170536';
  cmd[45] := '1705056500000000014100000000000000';
  cmd[46] := '1705050400000000014100000000000000';
  cmd[47] := '1705056701020000010600026768170433';
  cmd[48] := '1705056700000000014100000000000000';
  cmd[49] := '1719000000000000015000000000000000';
  cmd[50] := '1711051703180319010400041800041900';
  cmd[51] := '1726055003510000010500045100000000';
  cmd[52] := '1726055000000000012500000000000000';
  cmd[53] := '1711051700000000012500000000000000';
  cmd[54] := '1820057305530000015500000000000000';
  cmd[55] := '1820037305530000014500015500047300';
  cmd[56] := '1827056403650366011000013700046500';
  cmd[57] := '1820055303770000011000013700047700';
  cmd[58] := '1812000000000000013600000000000000';
  cmd[59] := '1900056101190000011800180000000000';
  cmd[60] := '1900057401190000011800010100000000';
  cmd[61] := '1900055401190000011800011300035400';
  cmd[62] := '1900055501190000011800010100000000';
  cmd[63] := '1900055801190000015700000000000000';
  cmd[64] := '1900057301190000011800010100000000';
  cmd[65] := '1900011900000000015600000000000000';
  cmd[66] := '1900000000000000015300000000000000';
  cmd[67] := '2000000000000000013100000000000000';
  cmd[68] := '2100000000000000014700000000000000';
  cmd[69] := '2200011400000000013300031400000000';
  cmd[70] := '2200000000000000015100000000000000';
  cmd[71] := '2323054300000000053000000000000000';
  cmd[72] := '2400016200000000013500026263770000';
  cmd[73] := '2400016300000000013400026263770000';
  cmd[74] := '2500016300000000013400026263770000';
  cmd[75] := '2600016200000000013500026263770000';
  cmd[76] := '2710011502550000011700021575050600';
  cmd[77] := '2710011500000000011700021575050800';
  cmd[78] := '2733015200000000015900025278000000';
  cmd[79] := '2721013600000000011600033600060000';
  cmd[80] := '2721000000000000013000000000000000';
  cmd[81] := '2710000000000000013000000000000000';
  cmd[82] := '2700000000000000015200000000000000';
  cmd[83] := '2800012300000000013200022325000000';
  cmd[84] := '2800000000000000010100000000000000';
  cmd[85] := '2934000000000000160000000000000000';
  cmd[86] := '3008057301120000011400097399041200';
  cmd[87] := '3008011200000000010100041200000000';
  cmd[88] := '3008000000000000015400000000000000';
  cmd[89] := '3100057301120000011400097399000000';
  cmd[90] := '3100011200000000010100000000000000';
  cmd[91] := '3100000000000000015400000000000000';
end;

procedure InitSynonyms;
begin
  w0 := 13;
  w1[1] := 'n';  w2[1] := 'nor';
  w1[2] := 's';  w2[2] := 'sou';
  w1[3] := 'e';  w2[3] := 'eas';
  w1[4] := 'w';  w2[4] := 'wes';
  w1[5] := 'u';  w2[5] := 'up';
  w1[6] := 'd';  w2[6] := 'dow';
  w1[7] := 'get'; w2[7] := 'tak';

  // "use" should not be a synonym of "shoot"
  //w1[8] := 'use'; w2[8] := 'sho';

  w1[9] := 'sea'; w2[9] := 'ope';
  w1[10] := 'att'; w2[10] := 'kil';
  w1[11] := 'fir'; w2[11] := 'sho';
  w1[12] := 'fee'; w2[12] := 'dro';
  w1[13] := 'giv'; w2[13] := 'dro';
  e4 := 'end';
end;

procedure InitEvents;
begin
  eMsg[1] := 'A black cat runs by';
  eMsg[2] := 'I heard a funny noise';
  eMsg[3] := 'I think I hear footsteps';
  eMsg[4] := 'Was that a scream I heard ?';
  eMsg[5] := 'I feel a chill';
  eMsg[6] := 'A spider runs by';
  eMsg[7] := 'I think I heard a door slam';
  hsMsg[1] := 'Who dares to enter this house';
  hsMsg[2] := 'You shall die...';
  hsMsg[3] := 'Get out, get out before it''s too late';
  e5 := 'the end';
end;

procedure DoLightCheck;
begin
  if (lu < 50) and (lf = 2) and (obLoc[lt] <> 0) then
  begin
    Writeln('You''re flashlight is getting dim!');
    lf := 1;
  end;
  if (lu < 38) and (lf = 1) and (obLoc[lt] <> 0) then
  begin
    Writeln('You''re flashlight is getting dimmer!!');
    lf := 0;
  end;
  if (lu < 25) and (lu > 0) and (obLoc[lt] <> 0) then
  begin
    Writeln;
    Writeln('LIGHT RUNS OUT IN ', lu, ' TURNS!');
  end;
  if (lu = 0) and (lf = 0) then
  begin
    Writeln('LIGHT HAS RUN OUT!!!');
    lf := -1;
    obLoc[lt] := 0;
  end;
end;

procedure DoRandomEvents;
label L4030, L3999;
begin
  if (obLoc[54] = r) or (obLoc[55] = r) or (obLoc[73] = r) or (obLoc[74] = r) then
  begin
    obLoc[61] := 0;
    Exit;
  end;
  if (r < 8) or (r = lb) or (r = dt) or (ht < 35) then Exit;
  if gn = 0 then Exit;
  if ga = 1 then
  begin
    obLoc[61] := r;
    goto L4030;
  end;
  if RndRange(32) = 7 then
  begin
    ga := 1;
    goto L3999;
  end;
  obLoc[61] := 0;
  Exit;
L4030:
  Writeln('There is a threatening little ghost in  the room with you!');
  gf := 1 - gf;
  if gf <> 0 then Exit;
  Writeln('The ghost attacks!');
  if RndRange(6) = 2 then
  begin
    Writeln('It got you!');
    r := lb;
    ga := 0;
    gk := 1;
    Exit;
  end;
  Writeln('It missed!');
L3999:
end;

procedure DoGhostAttack;
begin
  if RndRange(5) > 2 then
  begin
    Writeln('You missed!');
    Exit;
  end;
  Writeln('You got him!');
  Writeln('The ghost dissapears in a white mist!');
  gn := gn - 1;
  ga := 0;
  gf := 0;
  obLoc[61] := 0;
end;

procedure DoRoomFlavor;
begin
  if r = 27 then
    Writeln('A clock shows the time: ', Copy(tm, 1, 2), ':', Copy(tm, 3, 2));
  if ha = 1 then
  begin
    Writeln('The spirit of Hubie Marsten appears and says:');
    Writeln(hsMsg[RndRange(3)], '.');
    obLoc[74] := r;
    ha := 0;
  end;
  if (RndRange(5) = 4) and (r > 6) then
    Writeln(eMsg[RndRange(7)], '.');
  if (r > 3) and (r < 7) and (RndRange(4) = 2) then
    Writeln('The trees seem to be alive!');
  if (r > 32) and (r < 36) and (obLoc[74] <> r) then
    if RndRange(3) = 2 then ha := 1;
  if (obLoc[74] = r) and (RndRange(3) = 2) then
  begin
    Writeln('The spirit vanished??');
    obLoc[74] := 0;
    ha := 0;
  end;
  if (obLoc[54] = r) and (RndRange(3) = 2) then
  begin
    Writeln('The goblin attack with an axe in hand!');
    if RndRange(6) = 4 then
    begin
      Writeln('CRUNCH!!     He gets you!');
      r := lb;
      gk := 1;
      Exit;
    end;
    Writeln('WHOOSH!     He misses!');
  end;
  if (obLoc[55] = r) and (RndRange(3) = 2) then
  begin
    Writeln('The troll attacks!');
    if RndRange(7) = 6 then
    begin
      Writeln('He smashes your skull!');
      r := lb;
      gk := 1;
      Exit;
    end;
    Writeln('He missed!');
  end;
  if (obLoc[73] = r) and (RndRange(3) = 2) then
  begin
    Writeln('Barlow attacks!');
    if obLoc[38] = -1 then
    begin
      Writeln('He sees your cross and backs off!');
      Exit;
    end;
    if RndRange(4) = 3 then
    begin
      Writeln('He got you!!');
      r := lb;
      gk := 1;
      Exit;
    end;
    Writeln('He missed!');
  end;
end;

procedure TryTake(obj: Integer);
var
  pq, os: Integer;
begin
  if obSize[obj] = 1 then
  begin
    Writeln('IT''S BEYOND MY POWER TO DO THAT!');
    Exit;
  end;
  if obSize[obj] > 1 then
  begin
    Writeln('Don''t be stupid!');
    Exit;
  end;
  if obLoc[obj] = -1 then
  begin
    Writeln('I''m already carrying it.');
    Exit;
  end;
  if obLoc[obj] <> r then
  begin
    Writeln('I DON''T SEE IT HERE!');
    Exit;
  end;
  os := 0;
  for pq := 1 to MaxO do
    if obLoc[pq] = -1 then os := os + 1;
  if os + 1 > ol then
  begin
    Writeln('I''VE TOO MUCH TO CARRY');
    Exit;
  end;
  Writeln('ok,');
  obLoc[obj] := -1;
end;

procedure TryDropTreasure;
var
  td, tdPct: Integer;
begin
  tdPct := 0;
  for td := 1 to MaxO do
  begin
    if Copy(obName[td], 1, 1) <> '*' then Continue;
    if (td = 52) and (obLoc[td] = -1) and (obLoc[42] <> r) then
    begin
      Writeln(msg[24]);
      obLoc[52] := 0;
      obLoc[76] := r;
      Continue;
    end;
    if (td = 52) and (obLoc[td] = -1) then
    begin
      Writeln(msg[43]);
      obLoc[td] := r;
      Continue;
    end;
    if obLoc[td] = -1 then
    begin
      obLoc[td] := r;
      Writeln('dropped: ', obName[td]);
      tdPct := 1;
    end;
  end;
  if tdPct = 0 then Writeln('You have no treasure to drop.');
end;

procedure TryDropItem(obj: Integer);
begin
  if obLoc[obj] = -1 then
  begin
    obLoc[obj] := r;
    Writeln('ok,');
  end
  else
    Writeln('I''M NOT CARRYING IT!');
end;

procedure ShowInventory;
var
  i7, osFlag: Integer;
begin
  osFlag := 0;
  Writeln('I''M CARRYING:');
  for i7 := 1 to MaxO do
  begin
    if obLoc[i7] <> -1 then Continue;
    osFlag := 1;
    Writeln(obName[i7], '.  ');
  end;
  if osFlag <> 0 then Writeln;
  if osFlag = 0 then Writeln('nothing');
end;

procedure TryMove(dir: Integer);
begin
  if (rmExit[r, dir] = 0) and (df = 0) then
  begin
    Writeln('I CAN''T GO IN THAT DIRECTION.');
    Exit;
  end;
  if (rmExit[r, dir] = 0) and (df = 1) then
  begin
    Writeln('I FELL DOWN AND BROKE MY NECK!!');
    r := lb;
    so := so - 5;
    Exit;
  end;
  if (obLoc[54] = r) and (dir = 1) then
  begin
    Writeln('The goblin won''t let me by!');
    Exit;
  end;
  if (obLoc[55] = r) and (dir = 3) then
  begin
    Writeln('The troll is blocking my way!');
    Exit;
  end;
  r := rmExit[r, dir];
  rc := 1;
end;

procedure DoScore;
var
  i: Integer;
label EndScore;
begin
  sc := 0;
  for i := 1 to MaxO do
  begin
    if (Copy(obName[i], Length(obName[i]), 1) = '*') and (obLoc[i] = tr) then
      sc := sc + tv;
  end;
  if qf = 1 then so := so - 4;
  if so < 0 then so := 0;
  sc := sc + so;
  if qf = 1 then goto EndScore;
  Writeln('YOUR SCORE IS ', sc, ' OUT OF A POSSIBLE ', mxv);
  if sc - so = 300 then goto EndScore;
  Exit;
EndScore:
  Writeln('You scored ', sc, ' points.');
  Writeln('There were ', mxv, ' points possible.');
  if sc < 1 then
  begin
    Writeln('You must have nothing but space between youre ears!');
    Halt;
  end;
  if sc < 51 then
  begin
    Writeln('You are obviously a rank amateur.');
    Halt;
  end;
  if sc < 75 then
  begin
    Writeln('You''re score qualifies you as a novice  class adventurer.');
    Halt;
  end;
  if sc < 125 then
  begin
    Writeln('You''ve achieved the rating: Experienced Adventurer');
    Halt;
  end;
  if sc < 175 then
  begin
    Writeln('You have reached the ''junior master''    status.');
    Halt;
  end;
  if sc < 225 then
  begin
    Writeln('Your score puts you in MASTER ADVENTURER class -D-');
    Halt;
  end;
  if sc < 295 then
  begin
    Writeln('Your score puts you in MASTER ADVENTURER class -C-');
    Halt;
  end;
  if sc < 345 then
  begin
    Writeln('Your score puts you in MASTER ADVENTURER class -B-');
    Halt;
  end;
  if sc < 350 then
  begin
    Writeln('Your score puts you in MASTER ADVENTURER class -A-');
    Halt;
  end;
  if sc = mxv then
  begin
    Writeln('All of adventuredom gives tribute');
    Writeln('to you,  ADVENTURER GRAND MASTER!');
    Halt;
  end;
end;

procedure DoSave;
var
  f: TextFile;
  i: Integer;
begin
  Writeln('hit any key when tape is ready.');
  ReadLn;
  Assign(f, 'advent.sav');
  Rewrite(f);
  Writeln(f, r);
  Writeln(f, lu);
  Writeln(f, df);
  Writeln(f, lf);
  Writeln(f, so);
  Writeln(f, gn);
  Writeln(f, ga);
  Writeln(f, gf);
  for i := 1 to MaxO do
    Writeln(f, obLoc[i]);
  Close(f);
  Writeln('Game saved.');
end;

procedure DoLoad;
var
  f: TextFile;
  i, tmp: Integer;
begin
  Writeln('hit any key when tape is ready.');
  ReadLn;
  if not FileExists('advent.sav') then
  begin
    Writeln('No saved game found.');
    Exit;
  end;
  Assign(f, 'advent.sav');
  Reset(f);
  ReadLn(f, r);
  ReadLn(f, lu);
  ReadLn(f, df);
  ReadLn(f, lf);
  ReadLn(f, so);
  ReadLn(f, gn);
  ReadLn(f, ga);
  ReadLn(f, gf);
  for i := 1 to MaxO do
  begin
    ReadLn(f, tmp);
    obLoc[i] := tmp;
  end;
  Close(f);
  Writeln('Game loaded.');
end;

procedure ExecuteActions(cmdIdx: Integer);
var
  g: Integer;
begin
  g := 17;
  while g <= 34 do
  begin
    a1 := GetNum(cmd[cmdIdx], g, 2);
    a2 := GetNum(cmd[cmdIdx], g + 2, 2);
    a3 := GetNum(cmd[cmdIdx], g + 4, 2);

    if a1 = 1 then
    begin
      Writeln(msg[a2], '.');
    end;

    if a1 = 2 then
    begin
      ob := obLoc[a2];
      obLoc[a2] := obLoc[a3];
      obLoc[a3] := ob;
    end;

    if a1 = 3 then
    begin
      obLoc[a2] := 0;
    end;

    if a1 = 4 then
    begin
      obLoc[a2] := r;
    end;

    if a1 = 5 then
    begin
      r := a2;
      rc := 1;
    end;

    if a1 = 6 then
    begin
      dh := 1;
      r := lb;
      so := so - 5;
    end;

    if a1 = 7 then
    begin
      TryTake(i2);
    end;

    if a1 = 8 then
    begin
      if n1s <> 'TRE' then
      begin
        if i2s = '' then Writeln('be specific')
        else
          TryDropItem(i2);
      end
      else
        TryDropTreasure;
    end;

    if a1 = 9 then
    begin
      obLoc[a2] := a3;
    end;

    if a1 = 10 then
    begin
      ShowInventory;
    end;

    if a1 = 77 then
    begin
      dh := 1;
    end;

    if a1 = 18 then
    begin
      DoGhostAttack;
    end;

    if a1 = 11 then
    begin
      rc := 1;
    end;

    if a1 = 12 then
    begin
      DoScore;
    end;

    if a1 = 13 then
    begin
      qf := 1;
      DoScore;
    end;

    if a1 = 14 then
    begin
      h := a2;
      af := 1;
      if obLoc[h] = -1 then Writeln(msg[h])
      else Writeln('I have nothing to read');
    end;

    if a1 = 15 then
    begin
      e := a2;
      af := 1;
      if obLoc[e] = -1 then Writeln('thanks I was hungery')
      else Writeln('I have nothing to eat');
    end;

    if a1 = 16 then
    begin
      DoSave;
    end;

    g := g + 6;
  end;
end;

procedure MatchCommand;
var
  y, z: Integer;
  c1, c2: Integer;
label NextCmd, ExecuteIt;
begin
  mf := 0;
  k := 0;
  jp := 1;
  c7 := 53;
  if i1 > 17 then
  begin
    jp := 54;
    c7 := MaxC;
  end;
  for y := jp to c7 do
  begin
    if GetNum(cmd[y], 1, 2) <> i1 then Continue;
    if GetNum(cmd[y], 3, 2) <> 0 then
      if GetNum(cmd[y], 3, 2) <> i2 then Continue;
    k := 0;
    mf := 1;
    z := 5;
    while z <= 16 do
    begin
      c1 := GetNum(cmd[y], z, 2);
      c2 := GetNum(cmd[y], z + 2, 2);
      if c1 = 1 then
        if obLoc[c2] <> -1 then goto NextCmd;
      if c1 = 2 then
        if r <> c2 then goto NextCmd;
      if c1 = 3 then
        if obLoc[c2] <> 0 then goto NextCmd;
      if c1 = 5 then
        if obLoc[c2] <> r then goto NextCmd;
      k := k + 1;
      if k = 3 then
      begin
        an := y;
        goto ExecuteIt;
      end;
      z := z + 4;
    end;
NextCmd:
  end;
  if mf = 1 then
  begin
    Writeln('I CAN''T DO THAT NOW.');
    Exit;
  end;
  Writeln('I DON''T UNDERSTAND?');
  Exit;
ExecuteIt:
  af := 0;
  dh := 0;
  rf := 0;
  rc := 0;
  ExecuteActions(an);
  if dh = 1 then
  begin
    Writeln;
    Exit;
  end;
  if rc = 1 then
  begin
    Exit;
  end;
end;

function FindObject(const aKey: String): Integer;
var
  i: Integer;
begin
  for i := 1 to MaxO do
    if UpperCase(obKey[i]) = UpperCase(aKey) then
    begin
      FindObject := i;
      Exit;
    end;
  FindObject := 0;
end;

procedure ParseInput;
var
  spPos: Integer;
  w3, vl, nl: Integer;
begin
  if i1s = 'GO' then
  begin
    i1s := i2s;
    i2s := '';
  end;
  if i1s = 'SAY' then
  begin
    i1s := i2s;
    i2s := '';
  end;
  v1s := Copy(i1s, 1, 3);
  n1s := Copy(i2s, 1, 3);
  i1 := 0;
  i2 := 0;
  if (v1s = 'FEE') and (n1s = 'OYS') then n1s := 'DOO';
  for w3 := 1 to w0 do
    if v1s = UpperCase(w1[w3]) then v1s := UpperCase(w2[w3]);
  if (n1s = 'HOU') or (n1s = 'TRA') then n1s := 'DOO';
  for vl := 1 to MaxV do
    if v1s = UpperCase(verb[vl]) then
    begin
      i1 := vl;
      Break;
    end;
  if i2s <> '' then
  begin
    for nl := 1 to MaxN do
      if n1s = UpperCase(noun[nl]) then
      begin
        i2 := nl;
        Break;
      end;
  end;
  if i1 = 0 then
  begin
    Writeln('YOU USE WORD(S) I DON''T KNOW');
    Exit;
  end;
  if i1 < 7 then
  begin
    TryMove(i1 - 1);
    Exit;
  end;
  if i1 = 7 then
  begin
    TryTake(FindObject(n1s));
    Exit;
  end;
  MatchCommand;
end;

procedure DescribeRoom;
var
  x, uf, oe, vi: Integer;
label
  ShowDesc;
begin
  df := 0;
  if (r > dt) and (obLoc[lt] <> -1) and (obLoc[lt] <> r) then df := 1;
  if (r = lb) or (r = dt) then df := 0;
  if df = 0 then goto ShowDesc;
  Writeln('I CAN''T SEE IN THE DARK!');
  Writeln;
  Exit;
ShowDesc:
  if Copy(rmName[r], 1, 1) = '*' then
    rmName[r] := Copy(rmName[r], 2, Length(rmName[r]) - 1);
  Writeln('You''re in ', rmName[r], '.');
  if r = dt then
  begin
    Writeln;
    so := so - 12;
    qf := 1;
    Exit;
  end;
  x := 1;
  uf := 0;
  Writeln;
  for vi := 1 to MaxO do
  begin
    if (obLoc[vi] = r) and (x = 1) then
    begin
      Writeln('VISIBLE ITEMS HERE:');
      x := 0;
      uf := 1;
    end;
    if obLoc[vi] <> r then Continue;
    Writeln(obName[vi], '.  ');
  end;
  if uf <> 0 then Writeln;
  x := 1;
  Writeln;
  for oe := 0 to 5 do
  begin
    if (rmExit[r, oe] <> 0) and (x = 1) then
    begin
      Writeln('OBVIOUS EXITS:');
      x := 0;
    end;
    if rmExit[r, oe] <> 0 then Write(verb[oe + 1], ' ');
  end;
  Writeln;
  Writeln;
end;

procedure MainLoop;
var
  cmdInput: String;
  spPos: Integer;
begin
  if obLoc[lt] = -1 then lu := lu - 1;
  ht := ht + 1;
  DoLightCheck;
  DoRandomEvents;
  DoRoomFlavor;
  if gk = 1 then
  begin
    gk := 0;
    so := so - 5;
    Exit;
  end;
  Writeln;
  Write('WHAT NEXT   ');
  ReadLn(cmdInput);
  ip := cmdInput;
  if ip = '' then Exit;
  Writeln;
  i1s := '';
  i2s := '';
  spPos := Pos(' ', ip);
  if spPos > 0 then
  begin
    i1s := Copy(ip, 1, spPos - 1);
    i2s := Copy(ip, spPos + 1, Length(ip) - spPos);
  end
  else
    i1s := ip;
  i1s := UpperCase(i1s);
  i2s := UpperCase(i2s);
  ParseInput;
end;

procedure ShowIntro;
begin
  Writeln;
  Writeln('This is adventure!!!');
  Writeln('I will be your eyes and hands as you');
  Writeln('search for lost treasure.');
  Writeln;
  Writeln('The object is to recover ', t7, ' treasures');
  Writeln('and return them to the proper place.');
  Writeln('Treasures have a ''*'' in their name');
  Writeln;
  Writeln('Use two word commands consisting of');
  Writeln('a verb and a noun, example:');
  Writeln;
  Writeln('go west, take gold, enter hole, shoot');
  Writeln;
  Writeln('inventory, save game, drop treasure');
  Writeln('hit any key to continue');
  ReadKey;
  Writeln('       Words to Know                 ');
  Writeln('READ - if you have something that can be       read you will read it.');
  Writeln('ENTER - will take you into a hole,              passage, building, etc..');
  Writeln('INVENTORY - gives you list of what you              are carrying.');
  Writeln('LOOK - describes the room you are in.');
  Writeln;
  Writeln('Use TAKE and DROP in most cases to      manipulate objects.');
  Writeln;
  Writeln('There are many more words that will be  discovered as you explore some may');
  Writeln('even be magic, usually when you tell me things you should use two words.');
  Writeln;
  Writeln('If you find one word doesn''t work just  try another.');
  Writeln;
  Writeln('Please wait while I load my data...');
end;

procedure ShowTitle;
begin
  ClrScr;
  Writeln('                adventure  ');
  Writeln('      N  N        M        -by-     ');
  Writeln('     N  N      M     john o''hare ');
  Writeln('    N  N        M');
  Writeln('   N  N              M      VVVVVVV');
  Writeln('  N  N              M    VVMVVVNVV');
  Writeln('  P          VVVVVVVVV');
  Writeln('            VVVMNMNMVV');
  Writeln(' PP L     VVVVVVVVV');
  Writeln(' P  M               M    V  M N V');
  Writeln('     M               M  N   ');
  Writeln('M   OOPP      ');
  Writeln('PPPP   O        ');
  Writeln('   .       ');
  Writeln('L L     ');
  Writeln(' MM           M      ');
  Writeln('  PMOPOP     NVM');
  Writeln('      PPPPPPPPPPPOOOOO   ');
  Writeln('                  MM');
  Writeln('                    ');
  Writeln('                   M M');
  Writeln('  ');
  Writeln;
  Writeln('    hit any key to begin adventure');
  ReadKey;
end;

procedure InitializeGame;
begin
  Randomize;
  lt := 15;
  tv := 15;
  t7 := 20;
  mxv := tv * t7 + 50;
  ol := 10;
  tr := 7;
  lb := 57;
  dt := 58;
  ad := 3;
  lu := 150;
  lf := 2;
  gn := 4;
  so := 50;
  ht := 0;
  ha := 0;
  gf := 0;
  ga := 0;
  r := 1;
  df := 0;
  qf := 0;
  gk := 0;
  jp := 1;
end;

procedure LoadOrStart;
var
  g: String;
begin
  Writeln;
  Write('use saved game   n ');
  ReadLn(g);
  if g <> 'n' then
  begin
    DoLoad;
  end;
end;

begin
  InitNouns;
  InitVerbs;
  InitRooms;
  InitObjects;
  InitMessages;
  InitCommands;
  InitSynonyms;
  InitEvents;

  ShowTitle;
  ShowIntro;
  PauseAnyKey;

  InitializeGame;
  LoadOrStart;

  Writeln('What time is it (HHMM)');
  ReadLn(tm);
  if Length(tm) <> 4 then
  begin
    Writeln('illegal time');
    tm := '1200';
  end;

  while True do
  begin
    if r = dt then
    begin
      DoScore;
      Break;
    end;
    DescribeRoom;
    if qf = 1 then Break;
    if r = lb then
    begin
      r := 1;
      so := so - 5;
    end;
    MainLoop;
    if dh = 1 then
    begin
      dh := 0;
      r := lb;
      so := so - 5;
      gk := 1;
      Continue;
    end;
    if rc = 1 then
    begin
      rc := 0;
      Continue;
    end;
  end;

  Writeln;
  Writeln('Thanks for playing Adventure 1.5!');
end.

