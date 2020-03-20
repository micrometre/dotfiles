#!/bin/bash
echo ""
echo '<html>'
echo '<head>'
PATH="/bin:/usr/bin:/usr/ucb:/usr/opt/bin"
export $PATH
echo '<title>System Uptime</title>'
echo '</head>'
echo '<body>'
echo '</h3>'
echo "You said <$line>"
echo '</h3>'
echo ""
cat <<EOT
<!DOCTYPE html>
<html>
<head>
        <title>Welcome to our application</title>
</head>
<body>
        <p>Hello! Please enter your name and e-mail address and press the submit button</p>
        <form action="submit.sh" method="get">
                <label>Name</label>
                <input type="text" name="name">
                <br>
                <label>E-mail</label>
                <input type="text" name="email">
                <br>
                <button type="submit">Submit</button>
        </form>
</body>
</html>
EOT


















echo '</body>'
echo '</html>'
exit 0

