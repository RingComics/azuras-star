/**
 * Converts a PowerShell Object string into a JS Object.
 * PowerShell objects print with each property on a new line, this can be used to parse the output.
 * @param PSObjectString {string} - The object in format "key    : value"
 * @returns {{}} - Object containing key value pairs matching PS native objects
 */
const parsePSObjectString = (PSObjectString) =>
  PSObjectString.split(/\r?\n/).reduce((aggregator, PSProperty) => {
    // Split by the first ":" to get the key/value
    let [key, value] = PSProperty.split(/:(.+)/);
    if (!key) {
      // No key so just ignore
      // Possibly empty line printed by PS output
      return aggregator;
    }
    value = value || "";
    value = value.length > 0 ? value.trim() : "";
    return Object.assign({}, aggregator, { [key.trim()]: value });
  }, {});

const getProgramDetailsFromPS = async (program) => {
  await ps.addCommand(
    `return Get-ItemProperty HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\* | Where-Object DisplayName -like "${program}*"`
  );
  return parsePSObjectString(await ps.invoke());
};
p;
