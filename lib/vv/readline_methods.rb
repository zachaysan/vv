module Readline

  def vv_enabled?
    true
  end
  module_function :vv_enabled?

  def safe_readline(prompt)
    stty_save = `stty -g`.chomp
    begin
      Readline.readline prompt
    rescue Interrupt
      puts
      system("stty", stty_save)
      exit
    end
  end
  module_function :safe_readline

  def prompt message, exit_on_exit: true
    message.concat " "

    input = Readline.safe_readline message

    if input.nil?
      puts
      exit
    end

    input.chomp!

    exit if input == "exit" and exit_on_exit

    input
  end
  module_function :prompt

  def prompt_yn(message, default: nil)
    default = true  if default == "y" or default == "Y"
    default = false if default == "n" or default == "N"

    option = case default
             when nil
               "[y/n]"
             when false
               "[y/N]"
             when true
               "[Y/n]"
             end

    option.prepend " "
    message += option

    answer = nil

    loop do
      input = prompt(message)

      answer = default if input == ""
      answer = true  if input == "y" or input == "Y"
      answer = false if input == "n" or input == "N"

      break unless answer.nil?

      puts "Unrecognized input. Please enter response again."
    end

    answer
  end
  module_function :prompt_yn

end
