unit uEvolutionAPI.Token;

interface

uses
  System.SysUtils, System.Hash;

type
  TBeltToken = class
  public
    function GerarToken(const aValue: string): string;
  end;

implementation

function TBeltToken.GerarToken(const aValue: string): string;
var
  HashedToken: string;
begin
  HashedToken := THashSHA2.GetHashString(aValue);
  Result := HashedToken;
end;

end.

