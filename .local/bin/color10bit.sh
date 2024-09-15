#!/usr/bin/env sh
# Taken from https://github.com/BrodieRobertson/scripts/blob/master/color10bit

# Define the number of columns for the terminal width; default to 80 if tput fails
term_cols="${width:-$(tput cols || echo 80)}"

# Generate a color gradient
awk -v term_cols="$term_cols" '
BEGIN{
  s="/\\"; # Characters to display in gradient
  for (colnum = 0; colnum<term_cols; colnum++) {
    # Calculate RGB values for the gradient
    r = 255 - (colnum * 255 / term_cols);
    g = (colnum * 510 / term_cols);
    b = (colnum * 255 / term_cols);

    # Adjust green value if it exceeds 255
    if (g > 255) g = 510 - g;

    # Print the background color
    printf "\033[48;2;%d;%d;%dm", r, g, b;

    # Print the foreground color (inverse of the background color)
    printf "\033[38;2;%d;%d;%dm", 255 - r, 255 - g, 255 - b;

    # Print the character for the gradient
    printf "%s\033[0m", substr(s, colnum % 2 + 1, 1);
  }
  printf "\n"; # Newline at the end
}'
