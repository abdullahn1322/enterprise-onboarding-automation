function New-RandomPassword {

    param(
        [int]$Length = 16
    )

    $Upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $Lower = "abcdefghijklmnopqrstuvwxyz"
    $Numbers = "0123456789"
    $Special = "!@#$%^&*_-+="

    $Characters = ($Upper + $Lower + $Numbers + $Special).ToCharArray()

    $Password = ""

    for ($i = 1; $i -le $Length; $i++) {
        $Password += $Characters | Get-Random
    }

    return $Password
}